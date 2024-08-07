import { Controller, Get, Sse, Res, HttpStatus } from '@nestjs/common';
import { Response } from 'express';
import { AppService } from './app.service';
import { interval, map, Observable, take } from 'rxjs';
import { MessageEvent } from '@nestjs/common';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Sse('sse')
  sse(): Observable<MessageEvent> {
    return interval(10).pipe(map((_) => ({ data: 'world' })));
  }

  @Sse('sse-limited')
  sseLimited(): Observable<MessageEvent> {
    return interval(10).pipe(
      take(3),
      map(() => ({ data: 'world' }))
    );
  }

  @Get('sse-error')
  httpError(@Res() res: Response): void {
    res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({ message: 'Simulated Error' });
  }
}
