﻿namespace RemObjects.Train.API;

interface

uses
  RemObjects.Train,
  System.Linq,
  System.Threading,
  System.Text,
  RemObjects.Script.EcmaScript.Internal,
  System.IO,
  RemObjects.Script.EcmaScript,
  System.Security.Cryptography,
  Amazon.S3.*;

type

  [PluginRegistration]
  S3PlugIn = public class(IPluginRegistration)
  private
  protected
  public
    method &Register(aServices: IApiRegistrationServices);
    [WrapAs('S3.listFiles', SkipDryRun := true, wantSelf := true)]
    class method ListFiles(aServices: IApiRegistrationServices;  ec: ExecutionContext; aSelf: S3Engine; aPrefix, aSuffix: String): array of String;
    [WrapAs('S3.downloadFile', SkipDryRun := true, wantSelf := true)]
    class method DownloadFile(aServices: IApiRegistrationServices;  ec: ExecutionContext; aSelf: S3Engine; aKey, aLocalTarget: String);
    [WrapAs('S3.readFile', SkipDryRun := true, wantSelf := true)]
    class method ReadFile(aServices: IApiRegistrationServices;  ec: ExecutionContext; aSelf: S3Engine; aKey: String): String;
    [WrapAs('S3.downloadFiles', SkipDryRun := true, wantSelf := true)]
    class method DownloadFiles(aServices: IApiRegistrationServices;  ec: ExecutionContext; aSelf: S3Engine; aPrefix, aLocalTargetDir: String; aRecurse: Boolean);
    [WrapAs('S3.uploadFile', SkipDryRun := true, wantSelf := true)]
    class method UploadFile(aServices: IApiRegistrationServices;  ec: ExecutionContext; aSelf: S3Engine; aLocalFile, aKey: String);
    [WrapAs('S3.writeFile', SkipDryRun := true, wantSelf := true)]
    class method WriteFile(aServices: IApiRegistrationServices;  ec: ExecutionContext; aSelf: S3Engine; aString, aKey: String);
    [WrapAs('S3.uploadFiles', SkipDryRun := true, wantSelf := true)]
    class method UploadFiles(aServices: IApiRegistrationServices;  ec: ExecutionContext;aSelf: S3Engine;  aLocalFolderAndFilters, aPrefix: String; aRecurse: Boolean);

    [WrapAs('s3.bucket', wantSelf := true)]
    class method GetBucket(aServices: IApiRegistrationServices;  ec: ExecutionContext;aSelf: S3Engine): String;
    [WrapAs('s3.bucket', wantSelf := true)]
    class method SetBucket(aServices: IApiRegistrationServices;  ec: ExecutionContext;aSelf: S3Engine; val: String);

    [WrapAs('s3.serviceURL', wantSelf := true)]
    class method GetServiceURL(aServices: IApiRegistrationServices;  ec: ExecutionContext;aSelf: S3Engine): String;
    [WrapAs('s3.serviceURL', wantSelf := true)]
    class method SetServiceURL(aServices: IApiRegistrationServices;  ec: ExecutionContext;aSelf: S3Engine; val: String);

    [WrapAs('s3.accessKeyID', wantSelf := true)]
    class method GetAccessKeyID(aServices: IApiRegistrationServices;  ec: ExecutionContext;aSelf: S3Engine): String;
    [WrapAs('s3.accessKeyID', wantSelf := true, SecretArguments := [0])]
    class method SetAccessKeyID(aServices: IApiRegistrationServices;  ec: ExecutionContext;aSelf: S3Engine; val: String);

    [WrapAs('s3.secretAccessKey', wantSelf := true)]
    class method GetSecretAccessKey(aServices: IApiRegistrationServices;  ec: ExecutionContext;aSelf: S3Engine): String;
    [WrapAs('s3.secretAccessKey', wantSelf := true, SecretArguments := [0])]
    class method SetSecretAccessKey(aServices: IApiRegistrationServices;  ec: ExecutionContext;aSelf: S3Engine; val: String);

    [WrapAs('s3.regionEndpoint', wantSelf := true)]
    class method GetRegionEndpoint(aServices: IApiRegistrationServices;  ec: ExecutionContext;aSelf: S3Engine): String;
    [WrapAs('s3.regionEndpoint', wantSelf := true)]
    class method SetRegionEndpoint(aServices: IApiRegistrationServices;  ec: ExecutionContext;aSelf: S3Engine; val: String);
  end;
  
  S3Engine = public class
  private 
    fClient: AmazonS3Client;
    method GetClient: AmazonS3Client;
  assembly
    method ResetClient;
    property Bucket: String;
    property ServiceURL: String; 
    property AccessKeyID: String;
    property SecretAccessKey: String;
    property RegionEndpoint: String;
    property S3Client: AmazonS3Client read GetClient;
    property Timeout: TimeSpan := TimeSpan.FromSeconds(60);
  end;

implementation

method S3PlugIn.&Register(aServices: IApiRegistrationServices);
begin
  //aServices.RegisterValue('S3', RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(Self), 'Include'));
  var lProto := new EcmaScriptObject(aServices.Globals);
  lProto.Prototype := aServices.Globals.ObjectPrototype;
  lProto.AddValue('listFiles', RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'ListFiles'));
  lProto.AddValue('downloadFile', RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'DownloadFile'));
  lProto.AddValue('readFile', RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'ReadFile'));
  lProto.AddValue('downloadFiles', RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'DownloadFiles'));
  lProto.AddValue('uploadFile', RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'UploadFile'));
  lProto.AddValue('writeFile', RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'WriteFile'));
  lProto.AddValue('uploadFiles', RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'UploadFiles'));
  lProto.DefineOwnProperty('bucket', 
    new PropertyValue(PropertyAttributes.All, 
    RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'GetBucket'),
    RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'SetBucket')));
  lProto.DefineOwnProperty('serviceURL', 
    new PropertyValue(PropertyAttributes.All, 
    RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'GetServiceURL'),
    RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'SetServiceURL')));
  lProto.DefineOwnProperty('accessKeyID', 
    new PropertyValue(PropertyAttributes.All, 
    RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'GetAccessKeyID'),
    RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'SetAccessKeyID')));
  lProto.DefineOwnProperty('secretAccessKey', 
    new PropertyValue(PropertyAttributes.All, 
    RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'GetSecretAccessKey'),
    RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'SetSecretAccessKey')));
  lProto.DefineOwnProperty('regionEndpoint', 
    new PropertyValue(PropertyAttributes.All, 
    RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'GetRegionEndpoint'),
    RemObjects.Train.MUtilities.SimpleFunction(aServices.Engine, typeOf(S3PlugIn), 'SetRegionEndpoint')));

  var lObj := new EcmaScriptFunctionObject(aServices.Globals, 'S3', (aCaller, aSElf, aArgs) ->
    begin
      exit new WrapperObject(aCaller.Global, lProto, Val := new S3Engine);                                                                    
    end, 1, &Class := 'S3');
  aServices.Globals.Values.Add('S3', PropertyValue.NotEnum(lObj));

  lObj.Values['prototype'] := PropertyValue.NotAllFlags(lProto);
  lProto.Values['constructor'] := PropertyValue.NotEnum(lProto);
end;

{ S3 Logic }

class method S3PlugIn.ListFiles(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; aPrefix: String; aSuffix: String): array of String;
begin
  var lRequest := new ListObjectsRequest(BucketName := aSelf.Bucket, Prefix := aPrefix);
  result := aSelf.S3Client.ListObjects(lRequest):S3Objects:&Where(o -> (not assigned(aSuffix)) or o.Key.EndsWith(aSuffix)).Select(o -> o.Key).ToArray();
end;

class method S3PlugIn.DownloadFile(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; aKey: String; aLocalTarget: String);
begin
  aServices.Logger.LogMessage('Downloading {0} from S3 to {1}', aKey, aLocalTarget);
  Directory.CreateDirectory(Path.GetDirectoryName(aLocalTarget));
  using lRequest := new GetObjectRequest(BucketName := aSelf.Bucket, Key := aKey) do
    using lResult := aSelf.S3Client.GetObject(lRequest) do
      using s := lResult.ResponseStream do
        using w := new FileStream(aLocalTarget, FileMode.OpenOrCreate, FileAccess.Write, FileShare.Delete) do
          s.CopyTo(w);
end;

class method S3PlugIn.ReadFile(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; aKey: String): String;
begin
  using lRequest := new GetObjectRequest(BucketName := aSelf.Bucket, Key := aKey) do
    using lResult := aSelf.S3Client.GetObject(lRequest) do
      using s := lResult.ResponseStream do
        using r := new StreamReader(s) do
          result := r.ReadToEnd();
end;

class method S3PlugIn.DownloadFiles(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; aPrefix: String; aLocalTargetDir: String; aRecurse: Boolean);
begin
  var lFiles := ListFiles(aServices, ec, aSelf, aPrefix, nil);
  for each f in lFiles do begin
    var f2 := f.Substring(aPrefix.Length);
    var lFolder := Path.GetDirectoryName(f2);
    var lFile := Path.GetFileName(f2);
    var lTargetFile := Path.Combine(aLocalTargetDir, lFile);
    if length(lFolder) > 0 then begin
      if not aRecurse then 
        continue;
      lFolder := lFolder.Replace("/",Path.DirectorySeparatorChar);
      lTargetFile := Path.Combine(Path.Combine(aLocalTargetDir, lFolder), lFile);
    end;
    DownloadFile(aServices, ec, aSelf, f, lTargetFile);
  end;
end;

class method S3PlugIn.UploadFile(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; aLocalFile: String; aKey: String);
begin
  aServices.Logger.LogMessage('Uploading {0} to {1} on S3', aLocalFile, aKey);
  using lStream := new FileStream(aLocalFile, FileMode.Open, FileAccess.Read, FileShare.Delete) do
    using lRequest := new PutObjectRequest(BucketName := aSelf.Bucket, Key := aKey, InputStream := lStream, Timeout := aSelf.Timeout) do
      using lResponse := aSelf.S3Client.PutObject(lRequest) do;
end;

class method S3PlugIn.WriteFile(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; aString: String; aKey: String);
begin
  using lRequest := new PutObjectRequest(BucketName := aSelf.Bucket, Key := aKey, ContentBody := aString) do
    using lResponse := aSelf.S3Client.PutObject(lRequest) do;
end;

class method S3PlugIn.UploadFiles(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; aLocalFolderAndFilters: String; aPrefix: String; aRecurse: Boolean);
begin
  var lFolder := aLocalFolderAndFilters;
  var lFilter := Path.GetFileName(aLocalFolderAndFilters);
  if lFilter.Contains('*') or lFilter.Contains('?') then
    lFolder := Path.GetDirectoryName(lFolder)
  else
    lFilter := nil;
  
  var lFiles := if assigned(lFilter) then Directory.GetFiles(lFolder,lFilter) else Directory.GetFiles(lFolder);
  for each f in lFiles do
    UploadFile(aServices, ec, aSelf, f, aPrefix+Path.GetFileName(f));
  
  if aRecurse then begin
    var lFolders := Directory.GetDirectories(lFolder);
    for each f in lFolders do begin
      var f2 := if assigned(lFilter) then Path.Combine(f, lFilter) else f;
      UploadFiles(aServices, ec, aSelf, f2, Path.Combine(aPrefix, Path.GetFileName(f)), true);
    end;
  end;
end;

{ Properties }

class method S3PlugIn.GetBucket(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine): String;
begin
  result := aSelf.Bucket;
end;

class method S3PlugIn.SetBucket(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; val: String);
begin
  aSelf.Bucket := val;
  //aSelf.ResetClient();
end;

class method S3PlugIn.GetServiceURL(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine): String;
begin
  result := aSelf.ServiceURL;
end;

class method S3PlugIn.SetServiceURL(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; val: String);
begin
  aSelf.ServiceURL := val;
  aSelf.ResetClient();
end;

class method S3PlugIn.GetAccessKeyID(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine): String;
begin
  result := aSelf.AccessKeyID
end;

class method S3PlugIn.SetAccessKeyID(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; val: String);
begin
  aSelf.AccessKeyID := val;
  aSelf.ResetClient();
end;

class method S3PlugIn.GetSecretAccessKey(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine): String;
begin
  result := aSelf.SecretAccessKey
end;

class method S3PlugIn.SetSecretAccessKey(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; val: String);
begin
  aSelf.SecretAccessKey := val;
  aSelf.ResetClient();
end;

class method S3PlugIn.GetRegionEndpoint(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine): String;
begin
  result := aSelf.RegionEndpoint
end;

class method S3PlugIn.SetRegionEndpoint(aServices: IApiRegistrationServices; ec: ExecutionContext; aSelf: S3Engine; val: String);
begin
  aSelf.RegionEndpoint := val;
  aSelf.ResetClient();
end;

method S3Engine.GetClient: AmazonS3Client;
begin
  if not assigned(fClient) then begin
    var lConfig := new Amazon.S3.AmazonS3Config();
    lConfig.ServiceURL := if assigned(ServiceURL) then ServiceURL else 'https://s3.amazonaws.com';
    //if assigned(RegionEndpoint) then lConfig.RegionEndpoint := RegionEndpoint;
    fClient := new Amazon.S3.AmazonS3Client(AccessKeyID, SecretAccessKey{, lConfig});  
  end;
  result := fClient;
end;

method S3Engine.ResetClient;
begin
  fClient := nil;
end;

end.
