import { Controller, Sse } from '@nestjs/common';
import { AppService } from './app.service';
import { interval, map, Observable } from 'rxjs';
import { MessageEvent } from '@nestjs/common';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Sse('sse')
  sse(): Observable<MessageEvent> {
    return interval(1000).pipe(map((_) => ({ data: 'world' })));
  }
}
