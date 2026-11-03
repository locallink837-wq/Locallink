Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Drawing.Drawing2D
Add-Type -AssemblyName System.Speech

$ffmpeg = "C:\Program Files\AnyUkit\ffmpeg.exe"
$outDir = "$PWD\temp_render"
$framesDir = "$outDir\frames"
New-Item -ItemType Directory -Path $framesDir -Force | Out-Null

Write-Host ">>> LocaLink Video Production Generator Starting..." -ForegroundColor Cyan

# ==============================================================================
# Helper Drawing Functions
# ==============================================================================
function Create-RoundedPath([int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddArc($x, $y, $r*2, $r*2, 180, 90)
    $path.AddArc($x + $w - $r*2, $y, $r*2, $r*2, 270, 90)
    $path.AddArc($x + $w - $r*2, $y + $h - $r*2, $r*2, $r*2, 0, 90)
    $path.AddArc($x, $y + $h - $r*2, $r*2, $r*2, 90, 90)
    $path.CloseFigure()
    return $path
}

function Fill-Rounded([System.Drawing.Graphics]$g, [System.Drawing.Brush]$brush, [int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
    $path = Create-RoundedPath $x $y $w $h $r
    $g.FillPath($brush, $path)
    $path.Dispose()
}

function Draw-Rounded([System.Drawing.Graphics]$g, [System.Drawing.Pen]$pen, [int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
    $path = Create-RoundedPath $x $y $w $h $r
    $g.DrawPath($pen, $path)
    $path.Dispose()
}

function Draw-Touch([System.Drawing.Graphics]$g, [int]$x, [int]$y, [bool]$ripple) {
    $touchBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(120, 20, 184, 166))
    $touchPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(240, 94, 234, 212), 3)
    $g.FillEllipse($touchBrush, ($x - 22), ($y - 22), 44, 44)
    $g.DrawEllipse($touchPen, ($x - 22), ($y - 22), 44, 44)

    if ($ripple) {
        $ripPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(180, 45, 212, 191), 2)
        $g.DrawEllipse($ripPen, ($x - 38), ($y - 38), 76, 76)
        $ripPen.Dispose()
    }
    $touchBrush.Dispose()
    $touchPen.Dispose()
}

function Create-BaseCanvas {
    param(
        [string]$clipNum,
        [string]$clipTitle,
        [string]$narration,
        [string[]]$techPoints
    )

    $bmp = [System.Drawing.Bitmap]::new(1920, 1080)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # 1. Dark sleek background
    $bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        [System.Drawing.Point]::new(0, 0),
        [System.Drawing.Point]::new(1920, 1080),
        [System.Drawing.Color]::FromArgb(11, 17, 32),
        [System.Drawing.Color]::FromArgb(15, 23, 42)
    )
    $g.FillRectangle($bgBrush, 0, 0, 1920, 1080)
    $bgBrush.Dispose()

    # Subtle grid lines
    $gridPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(20, 255, 255, 255), 1)
    for ($x = 0; $x -lt 1920; $x += 80) { $g.DrawLine($gridPen, $x, 0, $x, 1080) }
    for ($y = 0; $y -lt 1080; $y += 80) { $g.DrawLine($gridPen, 0, $y, 1920, $y) }
    $gridPen.Dispose()

    # 2. Left Phone Mockup Frame
    $phoneX = 140
    $phoneY = 80
    $phoneW = 460
    $phoneH = 920

    $phoneBezel = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(20, 24, 33))
    Fill-Rounded $g $phoneBezel $phoneX $phoneY $phoneW $phoneH 54
    $phoneBezel.Dispose()

    $bezelPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(80, 100, 116, 139), 3)
    Draw-Rounded $g $bezelPen $phoneX $phoneY $phoneW $phoneH 54
    $bezelPen.Dispose()

    # Screen surface
    $screenX = $phoneX + 16
    $screenY = $phoneY + 16
    $screenW = $phoneW - 32
    $screenH = $phoneH - 32

    $screenBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(246, 248, 248))
    Fill-Rounded $g $screenBrush $screenX $screenY $screenW $screenH 40
    $screenBrush.Dispose()

    # Dynamic Island
    $islandBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::Black)
    Fill-Rounded $g $islandBrush ($phoneX + 180) ($phoneY + 22) 100 24 12
    $islandBrush.Dispose()

    # Phone Status Bar
    $fStatus = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $bDark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(30, 41, 59))
    $g.DrawString("9:41", $fStatus, $bDark, ($screenX + 24), ($screenY + 18))
    $g.DrawString("5G  100%", $fStatus, $bDark, ($screenX + $screenW - 95), ($screenY + 18))
    $fStatus.Dispose()

    # Bottom Home Indicator
    $barBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(148, 163, 184))
    Fill-Rounded $g $barBrush ($screenX + 130) ($screenY + $screenH - 14) 168 5 3
    $barBrush.Dispose()

    # 3. Right Side: Presentation Dashboard
    $sideX = 660

    # Brand badge
    $bTealBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(40, 13, 148, 136))
    Fill-Rounded $g $bTealBg $sideX 95 380 36 10
    $bTealBg.Dispose()

    $fBadge = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $bTealTxt = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(45, 212, 191))
    $g.DrawString("LOCALINK  •  PRIVACY-FIRST HYPERLOCAL", $fBadge, $bTealTxt, ($sideX + 14), 103)
    $fBadge.Dispose()
    $bTealTxt.Dispose()

    # Clip Number & Title
    $fClipNum = [System.Drawing.Font]::new("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
    $bClipNum = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(20, 184, 166))
    $g.DrawString($clipNum, $fClipNum, $bClipNum, $sideX, 150)
    $fClipNum.Dispose()
    $bClipNum.Dispose()

    $fTitle = [System.Drawing.Font]::new("Segoe UI", 34, [System.Drawing.FontStyle]::Bold)
    $bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $g.DrawString($clipTitle, $fTitle, $bWhite, $sideX, 185)
    $fTitle.Dispose()

    # Architecture / Technical Cards
    $cardY = 270
    foreach ($pt in $techPoints) {
        $cardBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(18, 30, 49))
        Fill-Rounded $g $cardBg $sideX $cardY 1120 74 14
        $cardBg.Dispose()

        $cardBorder = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(60, 51, 65, 85), 1.5)
        Draw-Rounded $g $cardBorder $sideX $cardY 1120 74 14
        $cardBorder.Dispose()

        $fIco = [System.Drawing.Font]::new("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
        $bCheck = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(16, 185, 129))
        $g.DrawString("[V]", $fIco, $bCheck, ($sideX + 16), ($cardY + 22))
        $fIco.Dispose()
        $bCheck.Dispose()

        $fCardTxt = [System.Drawing.Font]::new("Segoe UI", 14, [System.Drawing.FontStyle]::Regular)
        $bMuted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(226, 232, 240))
        $g.DrawString($pt, $fCardTxt, $bMuted, ($sideX + 54), ($cardY + 24))
        $fCardTxt.Dispose()
        $bMuted.Dispose()

        $cardY += 92
    }

    # Live Teleprompter Spoken Narration Box
    $teleY = 660
    $teleBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(15, 23, 42))
    Fill-Rounded $g $teleBg $sideX $teleY 1120 220 20
    $teleBg.Dispose()

    $telePen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(120, 13, 148, 136), 2)
    Draw-Rounded $g $telePen $sideX $teleY 1120 220 20
    $telePen.Dispose()

    $fTeleLabel = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $bTeleTeal = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(45, 212, 191))
    $g.DrawString("LIVE SPOKEN NARRATION (SYNCHRONIZED)", $fTeleLabel, $bTeleTeal, ($sideX + 24), ($teleY + 18))
    $fTeleLabel.Dispose()
    $bTeleTeal.Dispose()

    $fNarr = [System.Drawing.Font]::new("Segoe UI", 17, [System.Drawing.FontStyle]::Regular)
    $bNarr = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(241, 245, 249))
    $rectNarr = [System.Drawing.RectangleF]::new(($sideX + 24), ($teleY + 54), 1070, 145)
    $narrText = '"' + $narration + '"'
    $g.DrawString($narrText, $fNarr, $bNarr, $rectNarr)
    $fNarr.Dispose()
    $bNarr.Dispose()

    $bDark.Dispose()
    $bWhite.Dispose()

    return @{ Bitmap = $bmp; Graphics = $g; ScreenX = $screenX; ScreenY = $screenY; ScreenW = $screenW; ScreenH = $screenH }
}

# ==============================================================================
# SCENE 0: INTRO SCREEN
# ==============================================================================
Write-Host "Rendering Scene 0: Introduction..." -ForegroundColor Yellow
$bmpIntro = [System.Drawing.Bitmap]::new(1920, 1080)
$g = [System.Drawing.Graphics]::FromImage($bmpIntro)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

$bgIntro = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.Point]::new(0, 0), [System.Drawing.Point]::new(1920, 1080),
    [System.Drawing.Color]::FromArgb(10, 15, 30), [System.Drawing.Color]::FromArgb(15, 23, 42)
)
$g.FillRectangle($bgIntro, 0, 0, 1920, 1080)
$bgIntro.Dispose()

$cardBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(18, 28, 48))
Fill-Rounded $g $cardBrush 360 160 1200 760 36
$cardBrush.Dispose()

$cardPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(120, 13, 148, 136), 3)
Draw-Rounded $g $cardPen 360 160 1200 760 36
$cardPen.Dispose()

$fLogo = [System.Drawing.Font]::new("Segoe UI", 68, [System.Drawing.FontStyle]::Bold)
$bTeal = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(45, 212, 191))
$g.DrawString("LocaLink", $fLogo, $bTeal, 760, 240)
$fLogo.Dispose()

$fSub = [System.Drawing.Font]::new("Segoe UI", 24, [System.Drawing.FontStyle]::Regular)
$bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$g.DrawString("Privacy-First Hyperlocal Community Services Ecosystem", $fSub, $bWhite, 550, 360)
$fSub.Dispose()

$pillars = @(
    "[*] Zero-Leakage Privacy Quarantine",
    "[*] Gemini 1.5 Flash Multimodal Vision",
    "[*] Native Hindi & Marathi Engine",
    "[*] Zero-Billing OpenStreetMap Engine"
)
$px = 440
$py = 470
foreach ($p in $pillars) {
    $pBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(30, 41, 59))
    Fill-Rounded $g $pBg $px $py 500 68 16
    $pBg.Dispose()

    $pPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(71, 85, 105), 1.5)
    Draw-Rounded $g $pPen $px $py 500 68 16
    $pPen.Dispose()

    $fP = [System.Drawing.Font]::new("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
    $g.DrawString($p, $fP, $bWhite, ($px + 20), ($py + 20))
    $fP.Dispose()

    $px += 540
    if ($px -gt 1400) { $px = 440; $py += 95 }
}

$fStack = [System.Drawing.Font]::new("Segoe UI", 16, [System.Drawing.FontStyle]::Regular)
$bMuted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(148, 163, 184))
$g.DrawString("Built with Flutter 3.x - Cloud Firestore - Supabase Storage - Google AI SDK", $fStack, $bMuted, 580, 780)
$fStack.Dispose()
$bMuted.Dispose()

$bmpIntro.Save("$framesDir\c0_state1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmpIntro.Dispose()

# ==============================================================================
# SCENE 1: INSTANT LANGUAGE SWITCH
# ==============================================================================
Write-Host "Rendering Scene 1: Instant Language Switch..." -ForegroundColor Yellow
$langStates = @(
    @{ Lang = "en"; Title = "Choose language"; Sub = "You can change this later in Settings."; Btn = "Continue"; TouchX = 350; TouchY = 320; Name = "c1_state1" },
    @{ Lang = "hi"; Title = "Bhasha Chunein"; Sub = "Aap ise settings mein badal sakte hain."; Btn = "Aage Badhein"; TouchX = 350; TouchY = 430; Name = "c1_state2" },
    @{ Lang = "mr"; Title = "Bhasha Nivada"; Sub = "Tumhi he nantar settings madhe badlu shakta."; Btn = "Pudhe Ja"; TouchX = 350; TouchY = 540; Name = "c1_state3" }
)

$c1_pts = @(
    "ValueNotifier<String> reactive localization triggers O(1) frame rebuilds",
    "Zero app reload or splash screen interruption during language switch",
    "Preferences synchronously persisted to local disk SharedPreferences"
)
$c1_narr = "LocaLink is built for Bharat. With a single tap, residents and tradespeople can toggle between English, Hindi, and Marathi, rebuilding the UI instantly with zero app restart."

foreach ($ls in $langStates) {
    $canvas = Create-BaseCanvas -clipNum "FEATURE 1 OF 5" -clipTitle "Instant Language Switch" -narration $c1_narr -techPoints $c1_pts
    $g = $canvas.Graphics
    $sx = $canvas.ScreenX; $sy = $canvas.ScreenY; $sw = $canvas.ScreenW

    $fTitle = [System.Drawing.Font]::new("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
    $bDark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(15, 23, 42))
    $g.DrawString($ls.Title, $fTitle, $bDark, ($sx + 24), ($sy + 70))
    $fTitle.Dispose()

    $fSub = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Regular)
    $bMuted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(100, 116, 139))
    $g.DrawString($ls.Sub, $fSub, $bMuted, ($sx + 24), ($sy + 106))
    $fSub.Dispose()

    $tiles = @(
        @{ Code = "en"; Big = "English"; Small = "English"; Y = ($sy + 150) },
        @{ Code = "hi"; Big = "Hindi"; Small = "Hindi"; Y = ($sy + 250) },
        @{ Code = "mr"; Big = "Marathi"; Small = "Marathi"; Y = ($sy + 350) }
    )

    foreach ($t in $tiles) {
        $isSelected = ($t.Code -eq $ls.Lang)
        $tBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
        Fill-Rounded $g $tBg ($sx + 20) $t.Y ($sw - 40) 84 18
        $tBg.Dispose()

        $borderCol = if ($isSelected) { [System.Drawing.Color]::FromArgb(13, 148, 136) } else { [System.Drawing.Color]::FromArgb(226, 232, 240) }
        $tBorder = [System.Drawing.Pen]::new($borderCol, $(if ($isSelected) { 3 } else { 1.5 }))
        Draw-Rounded $g $tBorder ($sx + 20) $t.Y ($sw - 40) 84 18
        $tBorder.Dispose()

        $fBig = [System.Drawing.Font]::new("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
        $g.DrawString($t.Big, $fBig, $bDark, ($sx + 40), ($t.Y + 16))
        $fBig.Dispose()

        $fSmall = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Regular)
        $g.DrawString($t.Small, $fSmall, $bMuted, ($sx + 40), ($t.Y + 48))
        $fSmall.Dispose()

        $radCol = if ($isSelected) { [System.Drawing.Color]::FromArgb(13, 148, 136) } else { [System.Drawing.Color]::FromArgb(203, 213, 225) }
        $rPen = [System.Drawing.Pen]::new($radCol, 2.5)
        $g.DrawEllipse($rPen, ($sx + $sw - 70), ($t.Y + 28), 24, 24)
        $rPen.Dispose()

        if ($isSelected) {
            $rFill = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
            $g.FillEllipse($rFill, ($sx + $sw - 64), ($t.Y + 34), 12, 12)
            $rFill.Dispose()
        }
    }

    $btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
    Fill-Rounded $g $btnBg ($sx + 20) ($sy + 740) ($sw - 40) 62 18
    $btnBg.Dispose()

    $fBtn = [System.Drawing.Font]::new("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
    $bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $btnText = $ls.Btn + "  ->"
    $g.DrawString($btnText, $fBtn, $bWhite, ($sx + 140), ($sy + 756))
    $fBtn.Dispose()
    $bWhite.Dispose()

    Draw-Touch $g $ls.TouchX $ls.TouchY $true

    $canvas.Bitmap.Save("$framesDir\$($ls.Name).png", [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $canvas.Bitmap.Dispose()
}

# ==============================================================================
# SCENE 2: GEMINI 1.5 FLASH AI DIAGNOSIS
# ==============================================================================
Write-Host "Rendering Scene 2: Gemini 1.5 Flash AI Diagnosis..." -ForegroundColor Yellow

$c2_pts = @(
    "Multimodal vision pipeline passes compressed bytes directly to Gemini 1.5 Flash",
    "Enforces strict JSON schema validation for diagnosis, safety tips, and INR price",
    "Built-in rule-based heuristic fallback ensures zero crashes during offline states"
)
$c2_narr = "When an appliance breaks, residents do not need technical jargon. Gemini 1.5 Flash analyzes a photo of this leaking pipe, detects the failed valve, warns to shut off the main cock, gives a fair local price in Rupees, and identifies the exact trade needed."

# State 1: Photo uploaded
$c2_1 = Create-BaseCanvas -clipNum "FEATURE 2 OF 5" -clipTitle "Gemini 1.5 Flash AI Diagnosis" -narration $c2_narr -techPoints $c2_pts
$g = $c2_1.Graphics
$sx = $c2_1.ScreenX; $sy = $c2_1.ScreenY; $sw = $c2_1.ScreenW

$fHeader = [System.Drawing.Font]::new("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$bDark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(15, 23, 42))
$g.DrawString("Visual Problem Diagnosis", $fHeader, $bDark, ($sx + 24), ($sy + 70))
$fHeader.Dispose()

$pipeCard = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(30, 41, 59))
Fill-Rounded $g $pipeCard ($sx + 20) ($sy + 120) ($sw - 40) 240 20
$pipeCard.Dispose()

$pipePen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(148, 163, 184), 22)
$pipePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pipePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($pipePen, ($sx + 60), ($sy + 230), ($sx + 210), ($sy + 230))
$g.DrawLine($pipePen, ($sx + 210), ($sy + 230), ($sx + 210), ($sy + 310))
$pipePen.Dispose()

$brassBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(217, 119, 6))
Fill-Rounded $g $brassBrush ($sx + 195) ($sy + 205) 32 45 4
$brassBrush.Dispose()

$waterBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(56, 189, 248))
$g.FillEllipse($waterBrush, ($sx + 206), ($sy + 265), 10, 10)
$g.FillEllipse($waterBrush, ($sx + 204), ($sy + 285), 14, 14)
$waterBrush.Dispose()

$tagBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(180, 0, 0, 0))
Fill-Rounded $g $tagBrush ($sx + 35) ($sy + 315) 175 30 8
$tagBrush.Dispose()
$fTag = [System.Drawing.Font]::new("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$g.DrawString("demo_water_leak.png", $fTag, $bWhite, ($sx + 45), ($sy + 322))
$fTag.Dispose()

$descBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-Rounded $g $descBg ($sx + 20) ($sy + 380) ($sw - 40) 100 16
$descBg.Dispose()
$fDescHead = [System.Drawing.Font]::new("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$bMuted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(100, 116, 139))
$g.DrawString("USER PROBLEM NOTE", $fDescHead, $bMuted, ($sx + 36), ($sy + 395))
$fDescHead.Dispose()

$fDesc = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
$rectDesc = [System.Drawing.RectangleF]::new(($sx + 36), ($sy + 420), ($sw - 72), 50)
$g.DrawString("Bathroom tap pipe has continuous water leakage and low pressure under sink.", $fDesc, $bDark, $rectDesc)
$fDesc.Dispose()

$btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
Fill-Rounded $g $btnBg ($sx + 20) ($sy + 740) ($sw - 40) 62 18
$btnBg.Dispose()
$fBtn = [System.Drawing.Font]::new("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Analyze with Gemini AI", $fBtn, $bWhite, ($sx + 105), ($sy + 756))
$fBtn.Dispose()

Draw-Touch $g ($sx + $sw/2) ($sy + 770) $true

$c2_1.Bitmap.Save("$framesDir\c2_state1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c2_1.Bitmap.Dispose()

# State 2: Result Screen
$c2_2 = Create-BaseCanvas -clipNum "FEATURE 2 OF 5" -clipTitle "Gemini 1.5 Flash AI Diagnosis" -narration $c2_narr -techPoints $c2_pts
$g = $c2_2.Graphics
$sx = $c2_2.ScreenX; $sy = $c2_2.ScreenY; $sw = $c2_2.ScreenW

$badgeTeal = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(204, 251, 241))
Fill-Rounded $g $badgeTeal ($sx + 24) ($sy + 70) 130 32 8
$badgeTeal.Dispose()
$fBadge = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$bTealTxt = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
$g.DrawString("[OK] 94% Match", $fBadge, $bTealTxt, ($sx + 34), ($sy + 76))
$fBadge.Dispose()
$bTealTxt.Dispose()

$resCard = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-Rounded $g $resCard ($sx + 20) ($sy + 120) ($sw - 40) 115 18
$resCard.Dispose()

$fResHead = [System.Drawing.Font]::new("Segoe UI", 17, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Leaking Sink Angle Valve", $fResHead, $bDark, ($sx + 36), ($sy + 135))
$fResHead.Dispose()

$tradePill = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
Fill-Rounded $g $tradePill ($sx + 36) ($sy + 180) 100 32 8
$tradePill.Dispose()
$fPill = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Plumber", $fPill, $bWhite, ($sx + 56), ($sy + 186))
$fPill.Dispose()

$warnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 243, 199))
Fill-Rounded $g $warnBg ($sx + 20) ($sy + 250) ($sw - 40) 110 18
$warnBg.Dispose()
$warnPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(245, 158, 11), 1.5)
Draw-Rounded $g $warnPen ($sx + 20) ($sy + 250) ($sw - 40) 110 18
$warnPen.Dispose()

$fWarnHead = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$bAmber = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(180, 83, 9))
$g.DrawString("[!] EMERGENCY SAFETY PRECAUTION", $fWarnHead, $bAmber, ($sx + 36), ($sy + 265))
$fWarnHead.Dispose()
$bAmber.Dispose()

$fWarnTxt = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Regular)
$bWarnTxt = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(120, 53, 15))
$rectWarn = [System.Drawing.RectangleF]::new(($sx + 36), ($sy + 292), ($sw - 72), 55)
$g.DrawString("Turn off the main stopcock valve under basin immediately to prevent cabinet wood swelling.", $fWarnTxt, $bWarnTxt, $rectWarn)
$fWarnTxt.Dispose()
$bWarnTxt.Dispose()

$costBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-Rounded $g $costBg ($sx + 20) ($sy + 380) ($sw - 40) 100 18
$costBg.Dispose()
$fCostHead = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$g.DrawString("FAIR LABOR COST ESTIMATE", $fCostHead, $bMuted, ($sx + 36), ($sy + 395))
$fCostHead.Dispose()

$fPrice = [System.Drawing.Font]::new("Segoe UI", 26, [System.Drawing.FontStyle]::Bold)
$bPrice = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
$g.DrawString("Rs 250 - Rs 450", $fPrice, $bPrice, ($sx + 34), ($sy + 420))
$fPrice.Dispose()
$bPrice.Dispose()

$btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
Fill-Rounded $g $btnBg ($sx + 20) ($sy + 740) ($sw - 40) 62 18
$btnBg.Dispose()
$fBtn = [System.Drawing.Font]::new("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Book Verified Plumber  ->", $fBtn, $bWhite, ($sx + 85), ($sy + 756))
$fBtn.Dispose()

$c2_2.Bitmap.Save("$framesDir\c2_state2.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c2_2.Bitmap.Dispose()

# ==============================================================================
# SCENE 3: MAP DISCOVERY (OPENSTREETMAP)
# ==============================================================================
Write-Host "Rendering Scene 3: OpenStreetMap Map Discovery..." -ForegroundColor Yellow

$c3_pts = @(
    "flutter_map integration with cached OpenStreetMap raster tile layers",
    "Base32 Geohash B-tree indexing in Firestore avoids slow O(N) full-table scans",
    "Client-side Haversine mathematical calculation sorts nearest providers first"
)
$c3_narr = "LocaLink uses OpenStreetMap with tile caching, zero Google Maps API billing. Spatial geohashes query verified plumbers and electricians within five kilometers with real-time distance calculations."

$c3 = Create-BaseCanvas -clipNum "FEATURE 3 OF 5" -clipTitle "OpenStreetMap Spatial Discovery" -narration $c3_narr -techPoints $c3_pts
$g = $c3.Graphics
$sx = $c3.ScreenX; $sy = $c3.ScreenY; $sw = $c3.ScreenW; $sh = $c3.ScreenH

$mapCanvas = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(226, 232, 230))
Fill-Rounded $g $mapCanvas ($sx + 10) ($sy + 60) ($sw - 20) ($sh - 90) 24
$mapCanvas.Dispose()

$roadPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(203, 213, 225), 14)
$g.DrawLine($roadPen, ($sx + 20), ($sy + 180), ($sx + $sw - 20), ($sy + 240))
$g.DrawLine($roadPen, ($sx + 120), ($sy + 80), ($sx + 170), ($sy + 600))
$g.DrawLine($roadPen, ($sx + 280), ($sy + 80), ($sx + 260), ($sy + 600))
$g.DrawLine($roadPen, ($sx + 20), ($sy + 420), ($sx + $sw - 20), ($sy + 400))
$roadPen.Dispose()

$pills = @(
    @{ T = "All (9)"; Active = $false; X = ($sx + 24) },
    @{ T = "Services (4)"; Active = $true; X = ($sx + 110) },
    @{ T = "Places (3)"; Active = $false; X = ($sx + 230) },
    @{ T = "Shops (2)"; Active = $false; X = ($sx + 330) }
)
foreach ($pl in $pills) {
    $pBgCol = if ($pl.Active) { [System.Drawing.Color]::FromArgb(13, 148, 136) } else { [System.Drawing.Color]::White }
    $pBg = [System.Drawing.SolidBrush]::new($pBgCol)
    Fill-Rounded $g $pBg $pl.X ($sy + 80) 90 34 10
    $pBg.Dispose()

    $fPill = [System.Drawing.Font]::new("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $pTxtCol = if ($pl.Active) { [System.Drawing.Color]::White } else { [System.Drawing.Color]::FromArgb(71, 85, 105) }
    $bPTxt = [System.Drawing.SolidBrush]::new($pTxtCol)
    $g.DrawString($pl.T, $fPill, $bPTxt, ($pl.X + 8), ($sy + 88))
    $fPill.Dispose()
    $bPTxt.Dispose()
}

$pulseBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(50, 59, 130, 246))
$g.FillEllipse($pulseBrush, ($sx + 180), ($sy + 320), 60, 60)
$pulseBrush.Dispose()

$dotBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(37, 99, 235))
$g.FillEllipse($dotBrush, ($sx + 200), ($sy + 340), 20, 20)
$dotBrush.Dispose()

$mPin = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
$g.FillEllipse($mPin, ($sx + 175), ($sy + 220), 40, 40)
$mPin.Dispose()
$fWrench = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$g.DrawString("SVC", $fWrench, $bWhite, ($sx + 182), ($sy + 230))
$fWrench.Dispose()

$cardBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-Rounded $g $cardBg ($sx + 24) ($sy + 530) ($sw - 48) 190 20
$cardBg.Dispose()

$fName = [System.Drawing.Font]::new("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Pawar Plumbing & Sanitary", $fName, $bDark, ($sx + 40), ($sy + 546))
$fName.Dispose()

$fRating = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$bStar = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(217, 119, 6))
$g.DrawString("* 4.6 (28 reviews)  •  1.2 km away", $fRating, $bStar, ($sx + 40), ($sy + 580))
$fRating.Dispose()
$bStar.Dispose()

$fAddr = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Regular)
$g.DrawString("JM Road, Deccan Gymkhana, Pune", $fAddr, $bMuted, ($sx + 40), ($sy + 610))
$fAddr.Dispose()

$bCall = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
Fill-Rounded $g $bCall ($sx + 40) ($sy + 645) 160 48 12
$bCall.Dispose()
$fBtnSmall = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Call Provider", $fBtnSmall, $bWhite, ($sx + 65), ($sy + 658))

$bDir = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(241, 245, 249))
Fill-Rounded $g $bDir ($sx + 215) ($sy + 645) 160 48 12
$bDir.Dispose()
$g.DrawString("Directions", $fBtnSmall, $bDark, ($sx + 250), ($sy + 658))
$fBtnSmall.Dispose()

Draw-Touch $g ($sx + 195) ($sy + 240) $true

$c3.Bitmap.Save("$framesDir\c3_state1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c3.Bitmap.Dispose()

# ==============================================================================
# SCENE 4: PRIVACY FIREWALL & LEAD UNLOCK
# ==============================================================================
Write-Host "Rendering Scene 4: Privacy Quarantine & Lead Unlock..." -ForegroundColor Yellow

$c4_pts = @(
    "Customer phone & address isolated in requests/{id}/private/contact subcollection",
    "Firestore Security Rules reject queries until Cloud Function stamps providerId",
    "Concurrency-safe atomic transaction deducts flat Rs 25 micro-fee from wallet"
)
$c4_narr = "Customer privacy is strictly protected. Providers can see the neighborhood and problem, but the phone number is locked behind our privacy firewall. Upon paying a flat 25 rupee micro-fee, the verified customer contact unlocks instantly."

# State 1: Locked
$c4_1 = Create-BaseCanvas -clipNum "FEATURE 4 OF 5" -clipTitle "Zero-Leakage Privacy Quarantine" -narration $c4_narr -techPoints $c4_pts
$g = $c4_1.Graphics
$sx = $c4_1.ScreenX; $sy = $c4_1.ScreenY; $sw = $c4_1.ScreenW

$fHead = [System.Drawing.Font]::new("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Incoming Service Lead", $fHead, $bDark, ($sx + 24), ($sy + 70))
$fHead.Dispose()

$leadCard = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-Rounded $g $leadCard ($sx + 20) ($sy + 120) ($sw - 40) 140 18
$leadCard.Dispose()

$fLeadTitle = [System.Drawing.Font]::new("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Bathroom Pipeline Water Leakage", $fLeadTitle, $bDark, ($sx + 36), ($sy + 138))
$fLeadTitle.Dispose()

$fArea = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
$areaText = "Area: Model Colony, Pune (1.2 km away)"
$g.DrawString($areaText, $fArea, $bMuted, ($sx + 36), ($sy + 172))
$fArea.Dispose()

$privBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(238, 242, 255))
Fill-Rounded $g $privBg ($sx + 20) ($sy + 280) ($sw - 40) 120 18
$privBg.Dispose()
$privPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(99, 102, 241), 1.5)
Draw-Rounded $g $privPen ($sx + 20) ($sy + 280) ($sw - 40) 120 18
$privPen.Dispose()

$fPrivHead = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$bIndigo = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(67, 56, 202))
$g.DrawString("[LOCK]  ZERO-LEAKAGE PRIVACY QUARANTINE", $fPrivHead, $bIndigo, ($sx + 36), ($sy + 295))
$fPrivHead.Dispose()
$bIndigo.Dispose()

$fPrivTxt = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Regular)
$bPrivTxt = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(49, 46, 129))
$rectPriv = [System.Drawing.RectangleF]::new(($sx + 36), ($sy + 325), ($sw - 72), 65)
$g.DrawString("Customer verified phone number and door address unlock only after you accept the lead with credits.", $fPrivTxt, $bPrivTxt, $rectPriv)
$fPrivTxt.Dispose()
$bPrivTxt.Dispose()

$feeBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-Rounded $g $feeBg ($sx + 20) ($sy + 420) ($sw - 40) 70 16
$feeBg.Dispose()
$fFee = [System.Drawing.Font]::new("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Lead Unlock Fee:  Rs 25 Flat", $fFee, $bDark, ($sx + 36), ($sy + 444))
$fFee.Dispose()

$btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(79, 70, 229))
Fill-Rounded $g $btnBg ($sx + 20) ($sy + 740) ($sw - 40) 62 18
$btnBg.Dispose()
$fBtn = [System.Drawing.Font]::new("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Accept and Pay Rs 25  ->", $fBtn, $bWhite, ($sx + 95), ($sy + 756))
$fBtn.Dispose()

Draw-Touch $g ($sx + $sw/2) ($sy + 770) $true

$c4_1.Bitmap.Save("$framesDir\c4_state1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c4_1.Bitmap.Dispose()

# State 2: Unlocked Screen
$c4_2 = Create-BaseCanvas -clipNum "FEATURE 4 OF 5" -clipTitle "Zero-Leakage Privacy Quarantine" -narration $c4_narr -techPoints $c4_pts
$g = $c4_2.Graphics
$sx = $c4_2.ScreenX; $sy = $c4_2.ScreenY; $sw = $c4_2.ScreenW

$unlBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(236, 253, 245))
Fill-Rounded $g $unlBg ($sx + 20) ($sy + 70) ($sw - 40) 50 14
$unlBg.Dispose()
$fUnl = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$bGreen = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(5, 150, 105))
$g.DrawString("[OK]  Customer Phone Unlocked Successfully!", $fUnl, $bGreen, ($sx + 36), ($sy + 84))
$fUnl.Dispose()
$bGreen.Dispose()

$contCard = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-Rounded $g $contCard ($sx + 20) ($sy + 140) ($sw - 40) 250 20
$contCard.Dispose()

$avBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(224, 231, 255))
$g.FillEllipse($avBrush, ($sx + 36), ($sy + 160), 56, 56)
$avBrush.Dispose()
$fAv = [System.Drawing.Font]::new("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$bAv = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(67, 56, 202))
$g.DrawString("MJ", $fAv, $bAv, ($sx + 45), ($sy + 172))
$fAv.Dispose()
$bAv.Dispose()

$fCustName = [System.Drawing.Font]::new("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Meera Joshi", $fCustName, $bDark, ($sx + 106), ($sy + 160))
$fCustName.Dispose()

$fPhone = [System.Drawing.Font]::new("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$bPhone = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(5, 150, 105))
$g.DrawString("+91 94220 56789", $fPhone, $bPhone, ($sx + 106), ($sy + 192))
$fPhone.Dispose()
$bPhone.Dispose()

$fAddrHead = [System.Drawing.Font]::new("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$g.DrawString("EXACT DOOR ADDRESS", $fAddrHead, $bMuted, ($sx + 36), ($sy + 240))
$fAddrHead.Dispose()

$fAddrTxt = [System.Drawing.Font]::new("Segoe UI", 13, [System.Drawing.FontStyle]::Regular)
$g.DrawString("Flat 204, Om Residency, Model Colony, Pune", $fAddrTxt, $bDark, ($sx + 36), ($sy + 265))
$fAddrTxt.Dispose()

$btnCall = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(5, 150, 105))
Fill-Rounded $g $btnCall ($sx + 36) ($sy + 310) ($sw - 72) 54 14
$btnCall.Dispose()
$fCall = [System.Drawing.Font]::new("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Call Customer Directly", $fCall, $bWhite, ($sx + 105), ($sy + 325))
$fCall.Dispose()

$btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(79, 70, 229))
Fill-Rounded $g $btnBg ($sx + 20) ($sy + 740) ($sw - 40) 62 18
$btnBg.Dispose()
$fBtn = [System.Drawing.Font]::new("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$g.DrawString("I am on the way ->", $fBtn, $bWhite, ($sx + 120), ($sy + 756))
$fBtn.Dispose()

$c4_2.Bitmap.Save("$framesDir\c4_state2.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c4_2.Bitmap.Dispose()

# ==============================================================================
# SCENE 5: 1-TAP EMERGENCY SOS
# ==============================================================================
Write-Host "Rendering Scene 5: 1-Tap Emergency SOS..." -ForegroundColor Yellow

$c5_pts = @(
    "Works 100% without user login - zero auth gates during critical emergencies",
    "Direct OS telephone intent dispatch via url_launcher to 112 helpline",
    "Simultaneous hardware GPS reverse geocoding logs coordinates in background"
)
$c5_narr = "In an emergency, seconds count. LocaLink features a zero-login SOS hub that immediately launches India's 112 emergency helpline while capturing real-time GPS coordinates for broadcast."

$c5 = Create-BaseCanvas -clipNum "FEATURE 5 OF 5" -clipTitle "1-Tap National Emergency SOS" -narration $c5_narr -techPoints $c5_pts
$g = $c5.Graphics
$sx = $c5.ScreenX; $sy = $c5.ScreenY; $sw = $c5.ScreenW

$fSosHead = [System.Drawing.Font]::new("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Emergency Assistance", $fSosHead, $bDark, ($sx + 24), ($sy + 70))
$fSosHead.Dispose()

$sosCard = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 38, 38))
Fill-Rounded $g $sosCard ($sx + 20) ($sy + 120) ($sw - 40) 180 24
$sosCard.Dispose()

$f112 = [System.Drawing.Font]::new("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Call 112 Helpline", $f112, $bWhite, ($sx + 50), ($sy + 150))
$f112.Dispose()

$f112Sub = [System.Drawing.Font]::new("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
$bWhiteMuted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 202, 202))
$g.DrawString("National All-in-One Emergency Response Service", $f112Sub, $bWhiteMuted, ($sx + 44), ($sy + 215))
$f112Sub.Dispose()
$bWhiteMuted.Dispose()

$gpsBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(185, 28, 28))
Fill-Rounded $g $gpsBg ($sx + 40) ($sy + 245) ($sw - 80) 36 8
$gpsBg.Dispose()
$fGps = [System.Drawing.Font]::new("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$g.DrawString("GPS Logged: 18.5204 N, 73.8567 E (Pune)", $fGps, $bWhite, ($sx + 65), ($sy + 254))
$fGps.Dispose()

$helplines = @(
    @{ Name = "Police Control Room"; Num = "100" },
    @{ Name = "Ambulance Emergency"; Num = "108" },
    @{ Name = "Fire and Rescue Service"; Num = "101" }
)
$hy = ($sy + 330)
foreach ($h in $helplines) {
    $hBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    Fill-Rounded $g $hBg ($sx + 20) $hy ($sw - 40) 70 14
    $hBg.Dispose()

    $fHName = [System.Drawing.Font]::new("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
    $g.DrawString($h.Name, $fHName, $bDark, ($sx + 36), ($hy + 22))
    $fHName.Dispose()

    $fHNum = [System.Drawing.Font]::new("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
    $bRed = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 38, 38))
    $g.DrawString($h.Num, $fHNum, $bRed, ($sx + $sw - 90), ($hy + 20))
    $fHNum.Dispose()
    $bRed.Dispose()

    $hy += 85
}

$btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 38, 38))
Fill-Rounded $g $btnBg ($sx + 20) ($sy + 740) ($sw - 40) 62 18
$btnBg.Dispose()
$fBtn = [System.Drawing.Font]::new("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Alert Urgent Service Providers  ->", $fBtn, $bWhite, ($sx + 65), ($sy + 756))
$fBtn.Dispose()

Draw-Touch $g ($sx + $sw/2) ($sy + 180) $true

$c5.Bitmap.Save("$framesDir\c5_state1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c5.Bitmap.Dispose()

# ==============================================================================
# SCENE 6: OUTRO
# ==============================================================================
Write-Host "Rendering Scene 6: Outro..." -ForegroundColor Yellow
$bmpOutro = [System.Drawing.Bitmap]::new(1920, 1080)
$g = [System.Drawing.Graphics]::FromImage($bmpOutro)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

$bgOutro = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    [System.Drawing.Point]::new(0, 0), [System.Drawing.Point]::new(1920, 1080),
    [System.Drawing.Color]::FromArgb(10, 15, 30), [System.Drawing.Color]::FromArgb(15, 23, 42)
)
$g.FillRectangle($bgOutro, 0, 0, 1920, 1080)
$bgOutro.Dispose()

$cardBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(18, 28, 48))
Fill-Rounded $g $cardBrush 360 160 1200 760 36
$cardBrush.Dispose()

$cardPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(120, 13, 148, 136), 3)
Draw-Rounded $g $cardPen 360 160 1200 760 36
$cardPen.Dispose()

$fLogo = [System.Drawing.Font]::new("Segoe UI", 68, [System.Drawing.FontStyle]::Bold)
$bTeal = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(45, 212, 191))
$g.DrawString("LocaLink", $fLogo, $bTeal, 760, 220)
$fLogo.Dispose()

$fSub = [System.Drawing.Font]::new("Segoe UI", 26, [System.Drawing.FontStyle]::Bold)
$g.DrawString("Community First. Privacy Always.", $fSub, $bWhite, 710, 340)
$fSub.Dispose()

$summaryBullets = @(
    "[V] Complete Customer Privacy: No telephone cold-calling spam",
    "[V] Zero Percentage Commissions: Independent workers keep 100% of labor",
    "[V] Multimodal Intelligence: Gemini 1.5 Flash household problem diagnosis",
    "[V] Native Vernacular Engine: English, Hindi, and Marathi in a single tap",
    "[V] 100% Free Open-Source Mapping: Zero proprietary map billing"
)
$by = 430
foreach ($sb in $summaryBullets) {
    $fB = [System.Drawing.Font]::new("Segoe UI", 16, [System.Drawing.FontStyle]::Regular)
    $g.DrawString($sb, $fB, $bWhite, 480, $by)
    $fB.Dispose()
    $by += 55
}

$fThank = [System.Drawing.Font]::new("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
$bTeal = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(45, 212, 191))
$g.DrawString("Thank You - We Welcome Your Questions!", $fThank, $bTeal, 630, 780)
$fThank.Dispose()
$bTeal.Dispose()

$bmpOutro.Save("$framesDir\c6_state1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmpOutro.Dispose()

Write-Host ">>> All frames generated successfully!" -ForegroundColor Green

# ==============================================================================
# FFMPEG COMPILATION: Stitch Frames & Audio into MP4
# ==============================================================================
Write-Host ">>> Compiling intermediate video clips with FFmpeg..." -ForegroundColor Cyan

# Clip 0: Intro (5.24s)
& $ffmpeg -y -loop 1 -t 5.24 -i "$framesDir\c0_state1.png" -i "$outDir\audio_00_intro.wav" -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest "$outDir\clip0.mp4"

# Clip 1: Language Switch (9.84s = 3.2s + 3.3s + 3.34s)
$concatFile1 = "$outDir\c1_list.txt"
"file '$framesDir\c1_state1.png'`nduration 3.2`nfile '$framesDir\c1_state2.png'`nduration 3.3`nfile '$framesDir\c1_state3.png'`nduration 3.34`nfile '$framesDir\c1_state3.png'" | Set-Content $concatFile1
& $ffmpeg -y -f concat -safe 0 -i $concatFile1 -i "$outDir\audio_01_lang.wav" -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest "$outDir\clip1.mp4"

# Clip 2: Gemini AI (14.00s = 6.0s + 8.0s)
$concatFile2 = "$outDir\c2_list.txt"
"file '$framesDir\c2_state1.png'`nduration 6.0`nfile '$framesDir\c2_state2.png'`nduration 8.0`nfile '$framesDir\c2_state2.png'" | Set-Content $concatFile2
& $ffmpeg -y -f concat -safe 0 -i $concatFile2 -i "$outDir\audio_02_ai.wav" -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest "$outDir\clip2.mp4"

# Clip 3: Map Discovery (10.74s)
& $ffmpeg -y -loop 1 -t 10.74 -i "$framesDir\c3_state1.png" -i "$outDir\audio_03_map.wav" -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest "$outDir\clip3.mp4"

# Clip 4: Privacy Quarantine (13.11s = 5.5s + 7.61s)
$concatFile4 = "$outDir\c4_list.txt"
"file '$framesDir\c4_state1.png'`nduration 5.5`nfile '$framesDir\c4_state2.png'`nduration 7.61`nfile '$framesDir\c4_state2.png'" | Set-Content $concatFile4
& $ffmpeg -y -f concat -safe 0 -i $concatFile4 -i "$outDir\audio_04_privacy.wav" -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest "$outDir\clip4.mp4"

# Clip 5: Emergency SOS (10.83s)
& $ffmpeg -y -loop 1 -t 10.83 -i "$framesDir\c5_state1.png" -i "$outDir\audio_05_sos.wav" -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest "$outDir\clip5.mp4"

# Clip 6: Outro (8.33s)
& $ffmpeg -y -loop 1 -t 8.33 -i "$framesDir\c6_state1.png" -i "$outDir\audio_06_outro.wav" -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest "$outDir\clip6.mp4"

# Concat all 7 clips into master MP4
Write-Host ">>> Concatenating all clips into final LocaLink_Demo_Video.mp4..." -ForegroundColor Cyan
$masterList = "$outDir\master_list.txt"
"file '$outDir\clip0.mp4'`nfile '$outDir\clip1.mp4'`nfile '$outDir\clip2.mp4'`nfile '$outDir\clip3.mp4'`nfile '$outDir\clip4.mp4'`nfile '$outDir\clip5.mp4'`nfile '$outDir\clip6.mp4'" | Set-Content $masterList

$finalMp4Docs = "$PWD\docs\LocaLink_Demo_Video.mp4"
$finalMp4Root = "$PWD\LocaLink_Demo_Video.mp4"

& $ffmpeg -y -f concat -safe 0 -i $masterList -c copy $finalMp4Docs
Copy-Item $finalMp4Docs -Destination $finalMp4Root -Force

Write-Host ">>> SUCCESS! Video saved to:" -ForegroundColor Green
Write-Host "   1. $finalMp4Docs" -ForegroundColor Green
Write-Host "   2. $finalMp4Root" -ForegroundColor Green
