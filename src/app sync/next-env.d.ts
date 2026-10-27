/// <reference types="node" />

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

declare module 'crypto' {
  export function createHash(algorithm: string): {
    update(data: any): {
      digest(encoding: string): string;
    };
  };
  export function createHmac(algorithm: string, key: any): {
    update(data: any): {
      digest(encoding: string): string;
    };
  };
  export function randomBytes(size: number): any;
  const crypto: any;
  export default crypto;
}

declare var process: {
  env: Record<string, string | undefined>;
  [key: string]: any;
};

declare var Buffer: {
  from(data: any, encoding?: string): any;
  isBuffer(obj: any): boolean;
  concat(list: Uint8Array[], totalLength?: number): Buffer;
  [key: string]: any;
};
