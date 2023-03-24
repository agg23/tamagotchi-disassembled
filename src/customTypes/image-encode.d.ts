declare module "image-encode" {
  export default function encode(
    data: Buffer,
    shape: number[],
    options: {}
  ): ArrayBuffer;
}
