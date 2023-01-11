{
  $Project$
  $Workfile$
  $Revision$
  $DateUTC$
  $Id$

  This file is part of the Indy (Internet Direct) project, and is offered
  under the dual-licensing agreement described on the Indy website.
  (http://www.indyproject.org/)

  Copyright:
   (c) 1993-2005, Chad Z. Hower and the Indy Pit Crew. All rights reserved.
}
{
  $Log$
}
{
  Rev 1.11    2004.02.03 5:45:36 PM  czhower
  Name changes

  Rev 1.10    10/5/2003 11:44:06 PM  GGrieve
  Remove IdContainers

  Rev 1.9    9/18/2003 10:20:28 AM  JPMugaas
  Updated for new API.

    Rev 1.8    3/30/2003 12:38:56 AM  BGooijen
  Removed warning

    Rev 1.7    3/30/2003 12:15:12 AM  BGooijen
  Added MakeFTPSvrPort/MakeFTPSvrPasv

    Rev 1.6    3/23/2003 11:44:24 PM  BGooijen
  Added MakeClientIOHandler(ATheThread:TIdThreadHandle ):...

    Rev 1.5    3/14/2003 10:00:36 PM  BGooijen
  Removed TIdServerIOHandlerSSLBase.PeerPassthrough, the ssl is now enabled in
  the server-protocol-files

  Rev 1.3    3/13/2003 09:14:44 PM  JPMugaas
  Added property suggested by Henrick Hellstr�m (StreamSec) for checking a
  certificate against a URL provided by a user.

  Rev 1.2    3/13/2003 11:55:44 AM  JPMugaas
  Updated registration framework to give more information.

    Rev 1.1    3/13/2003 4:08:42 PM  BGooijen
  classes -> Classes

  Rev 1.0    3/13/2003 09:51:18 AM  JPMugaas
  Abstract SSL class to permit the clients and servers to use OpenSSL or
  third-party components SSL IOHandler.
}

unit IdSSL;

interface

{$i IdCompilerDefines.inc}

uses
  Classes,
  IdGlobal,
  IdIOHandler,
  IdIOHandlerSocket,
  IdIOHandlerStack,
  IdScheduler,
  IdServerIOHandler,
  IdYarn;

type
  TIdSSLVersion = (sslvSSLv2, sslvSSLv23, sslvSSLv3, sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2);
  TIdSSLVersions = set of TIdSSLVersion;

  //client
  TIdSSLIOHandlerSocketBase = class(TIdIOHandlerStack)
  protected
    fPassThrough: Boolean;
    fIsPeer : Boolean;
    FURIToCheck : String;
    function RecvEnc(var ABuffer: TIdBytes): Integer; virtual; abstract;
    function SendEnc(const ABuffer: TIdBytes; const AOffset, ALength: Integer): Integer; virtual; abstract;
    function ReadDataFromSource(var VBuffer: TIdBytes): Integer; override;
    function WriteDataToTarget(const ABuffer: TIdBytes; const AOffset, ALength: Integer): Integer; override;
    procedure SetPassThrough(const AValue: Boolean); virtual;
    procedure SetURIToCheck(const AValue: String); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    // TODO: add an AOwner parameter
    function Clone : TIdSSLIOHandlerSocketBase; virtual; abstract;
    procedure StartSSL; virtual; abstract;
    property PassThrough: Boolean read fPassThrough write SetPassThrough;
    property IsPeer : Boolean read fIsPeer write fIsPeer;
     {
Pasted from private corresponance from Henrick Hellstr�m - StreamSec http://www.streamsec.com

 This property should be set to the exact value of the URI passed to e.g.
TIdHTTP.Get and should not be used or modified by any code outside of
the SSL handler implementation units. The reason for this is that the
SSL/TLS handler should verify that the URI entered by the client user
matches the identity information present in the server certificate.
     }
    property URIToCheck : String read FURIToCheck write SetURIToCheck;
  end;

  //server
  TIdServerIOHandlerSSLBase = class(TIdServerIOHandler)
  protected
  public
    //this is for the FTP Server to make a client IOHandler for it's data connection's IOHandler
    function MakeClientIOHandler(ATheThread:TIdYarn ): TIdIOHandler; overload; override;
    function MakeClientIOHandler : TIdSSLIOHandlerSocketBase; reintroduce; overload; virtual; abstract;
    function MakeFTPSvrPort : TIdSSLIOHandlerSocketBase; virtual; abstract;
    function MakeFTPSvrPasv : TIdSSLIOHandlerSocketBase; virtual; abstract;
  end;

  TIdClientSSLClass = class of TIdSSLIOHandlerSocketBase;
  TIdServerSSLClass = class of TIdServerIOHandlerSSLBase;

implementation

{ TIdSSLIOHandlerSocketBase }

constructor TIdSSLIOHandlerSocketBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fPassThrough := True;
end;

function TIdSSLIOHandlerSocketBase.ReadDataFromSource(var VBuffer: TIdBytes): Integer;
begin
  if PassThrough then begin
    Result := inherited ReadDataFromSource(VBuffer);
  end else begin
    Result := RecvEnc(VBuffer);
  end;
end;

function TIdSSLIOHandlerSocketBase.WriteDataToTarget(const ABuffer: TIdBytes;
  const AOffset, ALength: Integer): Integer;
begin
  if PassThrough then begin
    Result := inherited WriteDataToTarget(ABuffer, AOffset, ALength);
  end else begin
    Result := SendEnc(ABuffer, AOffset, ALength);
  end;
end;

procedure TIdSSLIOHandlerSocketBase.SetPassThrough(const AValue: Boolean);
begin
  fPassThrough := AValue;
end;

procedure TIdSSLIOHandlerSocketBase.SetURIToCheck(const AValue: String);
begin
  FURIToCheck := AValue;
end;

{ TIdServerIOHandlerSSLBase }

function TIdServerIOHandlerSSLBase.MakeClientIOHandler(ATheThread: TIdYarn): TIdIOHandler;
begin
  Result := MakeClientIOHandler;
end;

end.