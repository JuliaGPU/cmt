/*
 * Copyright (c), Recep Aslantas.
 * MIT License (MIT), http://opensource.org/licenses/MIT
 */

#import "../include/cmtl/cmtl.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NSString*
mtNSString(const char *str) {
  return [NSString stringWithCString: str
                            encoding: NSUTF8StringEncoding];
}

MtDevice*
mtDeviceCreat() {
  id<MTLDevice> mdevice;
  mdevice = MTLCreateSystemDefaultDevice();
  return (void *)CFBridgingRetain(mdevice);
}

MtCommandQueue*
mtCommandQueue(MtDevice *device) {
  id<MTLDevice>       mdevice;
  id<MTLCommandQueue> mcmdQueue;

  mdevice   = (__bridge id<MTLDevice>)device;
  mcmdQueue = [mdevice newCommandQueue];

  return (void *)CFBridgingRetain(mcmdQueue);
}

MtRenderPipDesc*
mtPipelineDescCreat(MtPixelFormat pixelFormat) {
  MTLRenderPipelineDescriptor *mpipDesc;
  mpipDesc = [MTLRenderPipelineDescriptor new];
  mpipDesc.colorAttachments[0].pixelFormat = (MTLPixelFormat)pixelFormat;
  return (void *)CFBridgingRetain(mpipDesc);
}

MtLibrary*
mtDefaultLib(MtDevice *device) {
  id<MTLDevice>  mdevice;
  id<MTLLibrary> mlib;

  mdevice = (__bridge id<MTLDevice>)device;
  mlib    = [mdevice newDefaultLibrary];

  return (void *)CFBridgingRetain(mlib);
}

MtFunction*
mtFuncByName(MtLibrary *lib, const char *name) {
  id<MTLFunction> mfunc;
  id<MTLLibrary>  mlib;

  mlib  = (__bridge id<MTLLibrary>)lib;
  mfunc = [mlib newFunctionWithName: mtNSString(name)];

  if (mfunc == nil)
    return NULL;

  return (void *)CFBridgingRetain(mfunc);
}

void
mtPipelineSetFunc(MtRenderPipDesc *pipDesc,
                  MtFunction      *func,
                  MtFuncType       functype) {
  MTLRenderPipelineDescriptor *mpip;
  id<MTLFunction>              mfunc;

  mpip  = (__bridge MTLRenderPipelineDescriptor*)pipDesc;
  mfunc = (__bridge id<MTLFunction>)func;

  switch (functype) {
    case MT_FUNC_VERT:
      mpip.vertexFunction   = mfunc;
      break;
    case MT_FUNC_FRAG:
      mpip.fragmentFunction = mfunc;
      break;
    default: break;
  }
}

MtRenderPipState*
mtPiplineStateCreat(MtDevice *device, MtRenderPipDesc *pipDesc) {
  NSError                     *error;
  MTLRenderPipelineDescriptor *mpip;
  id <MTLRenderPipelineState>  mpipState;
  id<MTLDevice>                mdevice;

  mdevice   = (__bridge id<MTLDevice>)device;
  mpip      = (__bridge MTLRenderPipelineDescriptor*)pipDesc;
  mpipState = [mdevice newRenderPipelineStateWithDescriptor: mpip
                                                      error: &error];

  return (void *)CFBridgingRetain(mpipState);
}

MtRenderPassDesc*
mtPassCreat() {
  MTLRenderPassDescriptor *mrenderPassDesc;
  mrenderPassDesc = [MTLRenderPassDescriptor new];
  return (void *)CFBridgingRetain(mrenderPassDesc);
}

void
mtPassSetTexture(MtRenderPassDesc *pass,
                 int               colorAttch,
                 MtTexture        *tex) {
  MTLRenderPassDescriptor *mpass;
  id<MTLTexture>           mtex;

  mpass = (__bridge MTLRenderPassDescriptor*)pass;
  mtex  = (__bridge id<MTLTexture>)tex;

  mpass.colorAttachments[colorAttch].texture = mtex;
}

void
mtPassSetLoadAction(MtRenderPassDesc *pass,
                    int               colorAttch,
                    MtLoadAction      action) {
  MTLRenderPassDescriptor *mpass;

  mpass = (__bridge MTLRenderPassDescriptor*)pass;

  mpass.colorAttachments[colorAttch].loadAction = (MTLLoadAction)action;
}

MtCommandBuffer*
mtCommandBuff(MtCommandQueue *cmdq) {
  id<MTLCommandQueue>  mcmdQueue;
  id<MTLCommandBuffer> mcmdBuff;

  mcmdQueue = (__bridge id<MTLCommandQueue>)cmdq;
  mcmdBuff  = [mcmdQueue commandBuffer];

  return (void *)CFBridgingRetain(mcmdBuff);
}

void
mtCommandBuffPresentDrawable(MtCommandBuffer *cmdb, MtDrawable *drawable) {
  id<MTLCommandBuffer> mcmdBuff;
  id<MTLDrawable>      mdrawable;

  mcmdBuff  = (__bridge id<MTLCommandBuffer>)cmdb;
  mdrawable = (__bridge id<MTLDrawable>)cmdb;

  [mcmdBuff presentDrawable: mdrawable];
}

void
mtCommandBuffCommit(MtCommandBuffer *cmdb) {
  id<MTLCommandBuffer> mcmdBuff;

  mcmdBuff = (__bridge id<MTLCommandBuffer>)cmdb;

  [mcmdBuff commit];
}

MtRenderCommandEncoder*
mtRenderCommandEncoder(MtCommandBuffer *cmdb, MtRenderPassDesc *passDesc) {
  MTLRenderPassDescriptor    *mpass;
  id<MTLRenderCommandEncoder> mrenderEncoder;
  id<MTLCommandBuffer>        mcmdBuff;

  mcmdBuff       = (__bridge id<MTLCommandBuffer>)cmdb;
  mpass          = (__bridge MTLRenderPassDescriptor*)passDesc;
  mrenderEncoder = [mcmdBuff renderCommandEncoderWithDescriptor: mpass];

  return (void *)CFBridgingRetain(mrenderEncoder);
}

void
mtRCESetViewport(MtRenderCommandEncoder *enc, MtViewport *viewport) {
  id<MTLRenderCommandEncoder> mrenderEncoder;

  mrenderEncoder = (__bridge id<MTLRenderCommandEncoder>)enc;

  [mrenderEncoder setViewport: *(MTLViewport *)viewport];
}

void
mtRCESetPipState(MtRenderCommandEncoder *enc, MtRenderPipState *pipState) {
  id<MTLRenderCommandEncoder> mrenderEncoder;
  id<MTLRenderPipelineState>  mpipState;

  mrenderEncoder = (__bridge id<MTLRenderCommandEncoder>)enc;
  mpipState      = (__bridge id<MTLRenderPipelineState>)pipState;

  [mrenderEncoder setRenderPipelineState: mpipState];
}

void
mtRCESetVertexBytes(MtRenderCommandEncoder *enc,
                    void                   *bytes,
                    size_t                  legth,
                    uint32_t                atIndex) {
  id<MTLRenderCommandEncoder> mrenderEncoder;

  mrenderEncoder = (__bridge id<MTLRenderCommandEncoder>)enc;

  [mrenderEncoder setVertexBytes: bytes
                          length: legth
                         atIndex: atIndex];
}

void
mtRCEDrawPrimitives(MtRenderCommandEncoder *enc,
                    MtPrimitiveType         primType,
                    size_t                  vertStart,
                    size_t                  vertCount) {
  id<MTLRenderCommandEncoder> mrenderEncoder;

  mrenderEncoder = (__bridge id<MTLRenderCommandEncoder>)enc;

  [mrenderEncoder drawPrimitives: (MTLPrimitiveType)primType
                     vertexStart: vertStart
                     vertexCount: vertCount];
}

void
mtRCEEndEncoding(MtRenderCommandEncoder *enc) {
  id<MTLRenderCommandEncoder> mrenderEncoder;

  mrenderEncoder = (__bridge id<MTLRenderCommandEncoder>)enc;

  [mrenderEncoder endEncoding];
}
