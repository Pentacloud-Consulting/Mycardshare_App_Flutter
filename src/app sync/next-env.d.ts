declare module 'next/server' {
  export class NextResponse extends Response {
    static json(body: any, init?: ResponseInit): NextResponse;
    static redirect(url: string | URL, status?: number): NextResponse;
    static rewrite(destination: string | URL): NextResponse;
    static next(options?: any): NextResponse;
  }
  export interface NextRequest extends Request {
    nextUrl: URL;
  }
}
