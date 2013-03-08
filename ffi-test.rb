# -*- coding: utf-8 -*-
require 'ffi'

class String
  def to_ptr ; FFI::MemoryPointer.from_string self ; end
end

module Win
  extend FFI::Library
  ffi_lib 'crypt32'
  
=begin
typedef struct _CRYPTOAPI_BLOB {
  DWORD cbData;
  BYTE  *pbData;
} DATA_BLOB;
=end
  class DataBlob < FFI::Struct
    layout :cbData, :uint32,
      :pbData, :pointer

    def initialize s3kr1t=nil
      super nil
      self.data = s3kr1t
    end
    
    def data
      self[:pbData].read_string
    end

    def data= s3kr1t
      self[:pbData] = FFI::MemoryPointer.from_string(s3kr1t)
      self[:cbData] = s3kr1t.bytesize
    end
    
  end

=begin
BOOL WINAPI CryptProtectData(
  _In_      DATA_BLOB *pDataIn,
  _In_      LPCWSTR szDataDescr,
  _In_      DATA_BLOB *pOptionalEntropy,
  _In_      PVOID pvReserved,
  _In_opt_  CRYPTPROTECT_PROMPTSTRUCT *pPromptStruct,
  _In_      DWORD dwFlags,
  _Out_     DATA_BLOB *pDataOut
);
=end
  
  attach_function :CryptProtectData,
    [:pointer, :pointer, :pointer, :pointer, :pointer, :uint32, :pointer],
    :int32
  
end

noise = "meow"
blob = Win::DataBlob.new noise
puts "german cats say #{blob.data}"
