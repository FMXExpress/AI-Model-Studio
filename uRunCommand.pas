unit uRunCommand;

interface

  function RunCommand(const ACmd: string): string; forward;
  procedure OpenCmd(const ACmd: string); forward;

implementation

uses
  {$IFDEF MSWINDOWS}
  ShellAPI,
  Windows,
  {$ENDIF MSWINDOWS}
  {$IFDEF POSIX}
  Posix.Base,
  Posix.Fcntl,
  Posix.Stdio,
  Posix.Stdlib,
  {$ENDIF POSIX}
  System.SysUtils;

type
  TStreamHandle = pointer;

{$IFDEF MSWINDOWS}
function RunCommand(const ACmd: string): string;
var
  LStartupInfo: TStartupInfo;
  LProcessInfo: TProcessInformation;
  LSecurityAttributes: TSecurityAttributes;
  LReadPipe, LWritePipe: THandle;
  LBuffer: TBytes;
  LBytesRead: Cardinal;
  LCmd: string;
begin
  Result := String.Empty;

  // Set up security attributes to allow inheriting handles
  FillChar(LSecurityAttributes, SizeOf(LSecurityAttributes), 0);
  LSecurityAttributes.nLength := SizeOf(LSecurityAttributes);
  LSecurityAttributes.bInheritHandle := True;

  // Create pipes for standard output redirection
  if not CreatePipe(LReadPipe, LWritePipe, @LSecurityAttributes, 0) then
    raise Exception.Create('Failed to create pipe');

  try
    // Ensure the write end of the pipe is not inherited
    if not SetHandleInformation(LReadPipe, HANDLE_FLAG_INHERIT, 0) then
      raise Exception.Create('Failed to set handle information');

    FillChar(LStartupInfo, SizeOf(LStartupInfo), 0);
    LStartupInfo.cb := SizeOf(LStartupInfo);
    LStartupInfo.hStdOutput := LWritePipe;
    LStartupInfo.hStdError := LWritePipe;
    LStartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    LStartupInfo.wShowWindow := SW_HIDE;

    FillChar(LProcessInfo, SizeOf(LProcessInfo), 0);

    LCmd := 'cmd.exe /C ' + ACmd;
    UniqueString(LCmd);

    if not CreateProcess(
      nil,
      PChar(LCmd),
      nil,
      nil,
      True, // Inherit handles
      0,
      nil,
      nil,
      LStartupInfo,
      LProcessInfo
    ) then
      raise Exception.Create('Failed to create process.');

    CloseHandle(LWritePipe); // Close the write end in the parent process

    // Read the output from the pipe
    try
      SetLength(LBuffer, 4096);
      while True do
      begin
        if not ReadFile(LReadPipe, LBuffer[0], Length(LBuffer), LBytesRead, nil) or (LBytesRead = 0) then
          Break;

        Result := Result
          + TEncoding.UTF8.GetString(LBuffer, 0, Integer(LBytesRead));
      end;
    finally
      // Wait for the process to finish and clean up
      WaitForSingleObject(LProcessInfo.hProcess, INFINITE);
      CloseHandle(LProcessInfo.hProcess);
      CloseHandle(LProcessInfo.hThread);
    end;
  finally
    CloseHandle(LReadPipe);
  end;
end;

procedure OpenCmd(const ACmd: string);
begin
  ShellExecute(0, 'open', PChar(ACmd), nil, nil, SW_SHOWNORMAL);
end;
{$ENDIF MSWINDOWS}

{$IFDEF POSIX}
function popen(const command: MarshaledAString;
  const _type: MarshaledAString): TStreamHandle;
  cdecl; external libc name _PU + 'popen';

function pclose(filehandle: TStreamHandle): int32;
  cdecl; external libc name _PU + 'pclose';

function fgets(buffer: pointer; size: int32; Stream: TStreamHAndle): pointer;
  cdecl; external libc name _PU + 'fgets';

function BufferToString(const ABuffer: pointer; AMaxSize: UInt32): string;
var
  LCursor: ^uint8;
  LEndOfBuffer: nativeuint;
begin
  Result := '';

  if not Assigned(ABuffer) then
    Exit;

  LCursor := ABuffer;
  LEndOfBuffer := NativeUint(LCursor) + AMaxSize;
  while (NativeUInt(LCursor) < LEndOfBuffer) and (LCursor^ <> 0) do begin
    Result := Result + chr(LCursor^);
    LCursor := pointer(Succ(NativeUInt(LCursor)));
  end;
end;

function RunCommand(const ACmd: string): string;
var
  LHandle: TStreamHandle;
  LData: array[0..511] of uint8;
  LMarshaller: TMarshaller;
begin
  Result := String.Empty;

  LHandle := popen(LMarshaller.AsAnsi(ACmd).ToPointer(), 'r');
  try
    while fgets(@LData[0], SizeOf(LData), LHandle)<>nil do begin
      Result := Result + BufferToString(@LData[0], SizeOf(LData));
    end;
  finally
    pclose(LHandle);
  end;
end;

procedure OpenCmd(const ACmd: string);
var
  LMarshaller: TMarshaller;
begin
  _system(LMarshaller.AsAnsi('open ' + ACmd).ToPointer());
end;
{$ENDIF POSIX}

end.
