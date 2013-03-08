# -*- coding: utf-8 -*-
require 'ffi'
require 'win32/registry'

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
      self.data = s3kr1t unless s3kr1t.nil?
    end
    
    def data
      self[:pbData].get_bytes(0, self[:cbData])
    end

    def data= s3kr1t
      self[:pbData] = FFI::MemoryPointer.from_string(s3kr1t)
      self[:cbData] = s3kr1t.bytesize
    end
    
  end

  # http://www.pinvoke.net/default.aspx/Enums/CryptProtectFlags.html
  # dwFlags is a bitvector with the following values...
  CryptProtectFlags = {:UI_FORBIDDEN => 0x1,
    :LOCAL_MACHINE => 0x4,
    :CRED_SYNC => 0x8,
    :AUDIT => 0x10,
    :NO_RECOVERY => 0x20,
    :VERIFY_PROTECTION => 0x40
  }
  
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

=begin
BOOL WINAPI CryptUnprotectData(
  _In_        DATA_BLOB *pDataIn,
  _Out_opt_   LPWSTR *ppszDataDescr,
  _In_opt_    DATA_BLOB *pOptionalEntropy,
  _Reserved_  PVOID pvReserved,
  _In_opt_    CRYPTPROTECT_PROMPTSTRUCT *pPromptStruct,
  _In_        DWORD dwFlags,
  _Out_       DATA_BLOB *pDataOut
);    
=end
  attach_function :CryptUnprotectData,
    [:pointer, :pointer, :pointer, :pointer, :pointer, :uint32, :pointer],
    :int32
end

reg_keyname = "Software\\Heroku\\Toolbelt\\Creds"

if true
  plaintext  = Win::DataBlob.new
  ciphertext = Win::DataBlob.new
  Win32::Registry::HKEY_CURRENT_USER.open(reg_keyname) do |reg|
    ciphertext.data = reg.read_bin "somedude"
  end
  Win::CryptUnprotectData(ciphertext, nil, nil, nil, nil, 0,
                          plaintext)

  puts "plaintext should be \"#{plaintext.data}\""

end

if false
  noise = "Argle-bargle my friends, argle-bargle!"
  blob_in = Win::DataBlob.new noise
  puts "german cats say \"#{blob_in.data}\""
  blob_out = Win::DataBlob.new

  Win::CryptProtectData(blob_in, nil, nil, nil, nil, 0,
                        blob_out)

  puts "blob_out: #{blob_out[:cbData]} bytes long"
  #p "exit,no registry write" ; exit 0

  Win32::Registry::HKEY_CURRENT_USER.create(reg_keyname) do |reg|
    reg.write_bin "somedude", blob_out.data
  end
end

#Win.CryptProtectData blob, nil, nil, nil, nil,
#  Win::CryptProtectFlags[:AUDIT], 
