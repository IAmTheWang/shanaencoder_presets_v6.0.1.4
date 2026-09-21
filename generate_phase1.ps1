$presets = $PSScriptRoot

# ---- 1.1: 0cpuQualityGpt5.3CodexFastSameAudio (CRF 20-32) ----
$folder = "$presets\0cpuQualityGpt5.3CodexFastSameAudio"
New-Item -ItemType Directory -Path $folder -Force | Out-Null

$logoBlock = @'
 <Logo>
 <logochk>False</logochk>
 <logopath />
 <logoalign>7</logoalign>
 <logox>5</logox>
 <logoy>5</logoy>
 <logow>0</logow>
 <logoh>0</logoh>
 <logos>1</logos>
 <logosd>1</logosd>
 <logoe>9</logoe>
 <logoed>1</logoed>
 <logoschk>True</logoschk>
 <logoechk>True</logoechk>
 </Logo>
'@

$substyle = 'Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Microsoft YaHei UI,18,&H00FFFFFF,&H0000FFFF,&H00000000,&H80000000,-1,0,0,0,100,100,0,0,1,0.5,0,1,10,10,10,1'

20..32 | ForEach-Object {
    $crf = $_
    $content = @"
<?xml version="1.0" encoding="utf-8"?>
<!--ShanaEncoder-->
<Settings>
 <inputparamBox />
 <prefixtextBox />
 <extensiontextBox>[se6originAudioQualityCpuFast$crf].mp4</extensiontextBox>
 <filterparamBoxV> -vf "shanasubtitle=1"</filterparamBoxV>
 <filterparamBoxA />
 <encparamBox> -f mp4 -movflags faststart -timestamp now
 -c:v libx265 -tag:v hvc1 -crf $crf.0 -qmin 17 -qmax 36 -preset fast -tune:v none
 -c:a copy
 -sn -map_metadata -1 -map_chapters -1 -shanakeyframe 10 -assforcestyle</encparamBox>
 <x264optsBox />
 <substyle>$substyle</substyle>
 <fontnameSE />
$logoBlock</Settings>
"@
    $filename = "${crf}qualityCpuFastSameAudio.xml"
    [System.IO.File]::WriteAllText("$folder\$filename", $content, [System.Text.Encoding]::UTF8)
}
Write-Host "1.1: Created $((Get-ChildItem $folder -Filter *.xml).Count) FastSameAudio XML files"

# ---- 1.2: qualityQsv CQ 24-33 ----
$folder2 = "$presets\qualityQsv"

$logoBlock2 = @'
  <Logo>
    <logochk>False</logochk>
    <logopath />
    <logoalign>7</logoalign>
    <logox>5</logox>
    <logoy>5</logoy>
    <logow>0</logow>
    <logoh>0</logoh>
    <logos>1</logos>
    <logosd>1</logosd>
    <logoe>9</logoe>
    <logoed>1</logoed>
    <logoschk>True</logoschk>
    <logoechk>True</logoechk>
  </Logo>
'@

24..33 | ForEach-Object {
    $cq = $_
    $content = @"
<?xml version="1.0" encoding="utf-8"?>
<!--ShanaEncoder-->
<Settings>
  <inputparamBox />
  <prefixtextBox />
  <extensiontextBox>[se6qualityQsv$cq].mp4</extensiontextBox>
  <filterparamBoxV> -vf "shanasubtitle=1"</filterparamBoxV>
  <filterparamBoxA />
  <encparamBox> -f mp4  -timestamp now
 -c:v hevc_qsv -tag:v hvc1 -global_quality:v $cq -qmin 15 -qmax 35 -preset veryfast -profile:v main -level auto
 -c:a libfdk_aac -b:a 192k
 -sn -map_metadata -1 -map_chapters -1 -shanakeyframe 10 -assforcestyle</encparamBox>
  <x264optsBox />
  <substyle>$substyle</substyle>
  <fontnameSE />
$logoBlock2</Settings>
"@
    $filename = "${cq}qualityQsv.xml"
    [System.IO.File]::WriteAllText("$folder2\$filename", $content, [System.Text.Encoding]::UTF8)
}
Write-Host "1.2: Created $((Get-ChildItem $folder2 -Filter *.xml).Count) total QSV XML files (was 1, now $(1 + 10))"

# ---- 1.3: 3压 快速H265 8bit x265 - 1080p/1440p/2160p ----
$folder3 = "$presets\3压 快速H265 8bit x265"

$logoBlock3 = @'
  <Logo>
    <logochk>False</logochk>
    <logopath />
    <logoalign>7</logoalign>
    <logox>5</logox>
    <logoy>5</logoy>
    <logow>0</logow>
    <logoh>0</logoh>
    <logos>1</logos>
    <logosd>1</logosd>
    <logoe>9</logoe>
    <logoed>1</logoed>
    <logoschk>True</logoschk>
    <logoechk>True</logoechk>
  </Logo>
'@

# Bitrate values: scaled from 720p (1000k/2300k/4600k) using same ratios as 10bit sister folder
# 720p->1080p ratio from 10bit: 3800/1064=3.57x. Using ~2x for aggressive 3压 character.
$resolutions = @(
    @{ res='1080'; bv='2000k'; maxrate='4600k'; bufsize='9200k' },
    @{ res='1440'; bv='3600k'; maxrate='8000k'; bufsize='16000k' },
    @{ res='2160'; bv='6000k'; maxrate='14000k'; bufsize='28000k' }
)

foreach ($r in $resolutions) {
    $content = @"
<?xml version="1.0" encoding="utf-8"?>
<!--ShanaEncoder-->
<Settings>
  <inputparamBox />
  <prefixtextBox />
  <extensiontextBox />
  <filterparamBoxV> -vf "shanasubtitle=0,deblock=1"</filterparamBoxV>
  <filterparamBoxA />
  <encparamBox> -f mp4 -movflags faststart
 -c:v libx265 -tag:v hvc1 -preset veryfast -tune:v psnr -qmin 18 -b:v $($r.bv) -maxrate $($r.maxrate) -bufsize $($r.bufsize)
 -c:a copy
 -sn -timestamp now -shanakeyframe 10 -map_metadata -1 -map_chapters -1</encparamBox>
  <x264optsBox />
  <substyle>Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,,22,&H00FFFFFF,&H0000FFFF,&H00000000,&H80000000,-1,0,0,0,100,100,0,0,1,1,1,2,10,10,20,1</substyle>
  <fontnameSE />
$logoBlock3</Settings>
"@
    $filename = "308S_x265_$($r.res)_块_FMP4.xml"
    [System.IO.File]::WriteAllText("$folder3\$filename", $content, [System.Text.Encoding]::UTF8)
}
Write-Host "1.3: Created $((Get-ChildItem $folder3 -Filter *.xml).Count) total 3压快速 XML files (was 3, now 6)"
