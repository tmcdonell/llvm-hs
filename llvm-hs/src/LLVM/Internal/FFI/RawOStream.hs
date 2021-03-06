{-# LANGUAGE
  ForeignFunctionInterface
  #-}
module LLVM.Internal.FFI.RawOStream where

import LLVM.Prelude

import Foreign.Ptr
import Foreign.C
import Control.Exception (bracket)

import LLVM.Internal.FFI.ByteRangeCallback
import LLVM.Internal.FFI.LLVMCTypes

data RawOStream
data RawPWriteStream

type RawOStreamCallback = Ptr RawOStream -> IO ()
foreign import ccall "wrapper" wrapRawOStreamCallback ::
  RawOStreamCallback -> IO (FunPtr RawOStreamCallback)

foreign import ccall safe "LLVM_Hs_WithFileRawOStream" withFileRawOStream' ::
  CString -> LLVMBool -> LLVMBool -> Ptr (OwnerTransfered CString) -> FunPtr RawOStreamCallback -> IO LLVMBool
 
withFileRawOStream :: CString -> LLVMBool -> LLVMBool -> Ptr (OwnerTransfered CString) -> RawOStreamCallback -> IO LLVMBool
withFileRawOStream p ex bin err c = 
  bracket (wrapRawOStreamCallback c) freeHaskellFunPtr (withFileRawOStream' p ex bin err)

foreign import ccall safe "LLVM_Hs_WithBufferRawOStream" withBufferRawOStream' ::
  FunPtr ByteRangeCallback -> FunPtr RawOStreamCallback -> IO ()

withBufferRawOStream :: ByteRangeCallback -> RawOStreamCallback -> IO ()
withBufferRawOStream oc c = 
  bracket (wrapRawOStreamCallback c) freeHaskellFunPtr $ \c -> 
  bracket (wrapByteRangeCallback oc) freeHaskellFunPtr $ \oc ->
    withBufferRawOStream' oc c
