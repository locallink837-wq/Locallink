Add-Type -AssemblyName System.Drawing

$ffmpeg = "C:\Program Files\AnyUkit\ffmpeg.exe"
$outDir = "$PWD\temp_clean_clips"
$framesDir = "$outDir\frames"
$clipsDocs = "$PWD\docs\clips"
$clipsRoot = "$PWD\clips"

New-Item -ItemType Directory -Path $framesDir -Force | Out-Null
New-Item -ItemType Directory -Path $clipsDocs -Force | Out-Null
New-Item -ItemType Directory -Path $clipsRoot -Force | Out-Null

Write-Host ">>> LocaLink Pure Screen-Only 5-Second Video Generator Starting..." -ForegroundColor Cyan

function Create-Path([int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddArc($x, $y, $r*2, $r*2, 180, 90)
    $path.AddArc($x + $w - $r*2, $y, $r*2, $r*2, 270, 90)
    $path.AddArc($x + $w - $r*2, $y + $h - $r*2, $r*2, $r*2, 0, 90)
    $path.AddArc($x, $y + $h - $r*2, $r*2, $r*2, 90, 90)
    $path.CloseFigure()
    return $path
}

function Fill-RRect([System.Drawing.Graphics]$g, [System.Drawing.Brush]$brush, [int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
    $path = Create-Path $x $y $w $h $r
    $g.FillPath($brush, $path)
    $path.Dispose()
}

function Draw-RRect([System.Drawing.Graphics]$g, [System.Drawing.Pen]$pen, [int]$x, [int]$y, [int]$w, [int]$h, [int]$r) {
    $path = Create-Path $x $y $w $h $r
    $g.DrawPath($pen, $path)
    $path.Dispose()
}

function Draw-Touch([System.Drawing.Graphics]$g, [int]$x, [int]$y, [bool]$ripple) {
    $touchBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(110, 20, 184, 166))
    $touchPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(230, 94, 234, 212), 4)
    $g.FillEllipse($touchBrush, ($x - 30), ($y - 30), 60, 60)
    $g.DrawEllipse($touchPen, ($x - 30), ($y - 30), 60, 60)

    if ($ripple) {
        $ripPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(180, 45, 212, 191), 3)
        $g.DrawEllipse($ripPen, ($x - 55), ($y - 55), 110, 110)
        $ripPen.Dispose()
    }
    $touchBrush.Dispose()
    $touchPen.Dispose()
}

function Create-MobileCanvas {
    $bmp = [System.Drawing.Bitmap]::new(1080, 1920)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    $g.Clear([System.Drawing.Color]::FromArgb(246, 248, 248))

    $fTime = [System.Drawing.Font]::new('Segoe UI', 26, [System.Drawing.FontStyle]::Bold)
    $bDark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(30, 41, 59))
    $g.DrawString('9:41', $fTime, $bDark, 70, 45)
    $fTime.Dispose()

    $island = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::Black)
    Fill-RRect $g $island 430 35 220 54 27
    $island.Dispose()

    $fIcons = [System.Drawing.Font]::new('Segoe UI', 24, [System.Drawing.FontStyle]::Bold)
    $g.DrawString('5G  100%', $fIcons, $bDark, 870, 45)
    $fIcons.Dispose()
    $bDark.Dispose()

    $bar = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(148, 163, 184))
    Fill-RRect $g $bar 370 1895 340 10 5
    $bar.Dispose()

    return @{ Bitmap = $bmp; Graphics = $g }
}

# ==============================================================================
# CLIP 1: INSTANT LANGUAGE SWITCH
# ==============================================================================
Write-Host 'Rendering Clip 1: Language Switch...' -ForegroundColor Yellow

$c1_states = @(
    @{ Lang = 'en'; Title = 'Choose language'; Sub = 'You can change this later in Settings.'; Btn = 'Continue'; TouchX = 540; TouchY = 640; TouchOn = $true; Name = 'c1_s1' },
    @{ Lang = 'hi'; Title = 'Bhasha Chunein'; Sub = 'Aap ise settings mein badal sakte hain.'; Btn = 'Aage Badhein'; TouchX = 540; TouchY = 860; TouchOn = $true; Name = 'c1_s2' },
    @{ Lang = 'mr'; Title = 'Bhasha Nivada'; Sub = 'Tumhi he nantar settings madhe badlu shakta.'; Btn = 'Pudhe Ja'; TouchX = 540; TouchY = 1805; TouchOn = $true; Name = 'c1_s3' }
)

foreach ($st in $c1_states) {
    $canvas = Create-MobileCanvas
    $g = $canvas.Graphics

    $fTitle = [System.Drawing.Font]::new('Segoe UI', 44, [System.Drawing.FontStyle]::Bold)
    $bDark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(15, 23, 42))
    $g.DrawString($st.Title, $fTitle, $bDark, 50, 150)
    $fTitle.Dispose()

    $fSub = [System.Drawing.Font]::new('Segoe UI', 24, [System.Drawing.FontStyle]::Regular)
    $bMuted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(100, 116, 139))
    $g.DrawString($st.Sub, $fSub, $bMuted, 50, 220)
    $fSub.Dispose()

    $tiles = @(
        @{ Code = 'en'; Big = 'English'; Small = 'English'; Y = 320 },
        @{ Code = 'hi'; Big = 'Hindi'; Small = 'Hindi'; Y = 540 },
        @{ Code = 'mr'; Big = 'Marathi'; Small = 'Marathi'; Y = 760 }
    )

    foreach ($t in $tiles) {
        $isSelected = ($t.Code -eq $st.Lang)
        $tBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
        Fill-RRect $g $tBg 50 $t.Y 980 180 32
        $tBg.Dispose()

        $borderCol = if ($isSelected) { [System.Drawing.Color]::FromArgb(13, 148, 136) } else { [System.Drawing.Color]::FromArgb(226, 232, 240) }
        $tBorder = [System.Drawing.Pen]::new($borderCol, $(if ($isSelected) { 5 } else { 2.5 }))
        Draw-RRect $g $tBorder 50 $t.Y 980 180 32
        $tBorder.Dispose()

        $fBig = [System.Drawing.Font]::new('Segoe UI', 36, [System.Drawing.FontStyle]::Bold)
        $g.DrawString($t.Big, $fBig, $bDark, 95, ($t.Y + 40))
        $fBig.Dispose()

        $fSmall = [System.Drawing.Font]::new('Segoe UI', 22, [System.Drawing.FontStyle]::Regular)
        $g.DrawString($t.Small, $fSmall, $bMuted, 95, ($t.Y + 105))
        $fSmall.Dispose()

        $radCol = if ($isSelected) { [System.Drawing.Color]::FromArgb(13, 148, 136) } else { [System.Drawing.Color]::FromArgb(203, 213, 225) }
        $rPen = [System.Drawing.Pen]::new($radCol, 4)
        $g.DrawEllipse($rPen, 920, ($t.Y + 65), 50, 50)
        $rPen.Dispose()

        if ($isSelected) {
            $rFill = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
            $g.FillEllipse($rFill, 933, ($t.Y + 78), 24, 24)
            $rFill.Dispose()
        }
    }

    $btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
    Fill-RRect $g $btnBg 50 1750 980 110 32
    $btnBg.Dispose()

    $fBtn = [System.Drawing.Font]::new('Segoe UI', 32, [System.Drawing.FontStyle]::Bold)
    $bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    $btnText = $st.Btn + '  ->'
    $g.DrawString($btnText, $fBtn, $bWhite, 410, 1780)
    $fBtn.Dispose()
    $bWhite.Dispose()
    $bDark.Dispose()
    $bMuted.Dispose()

    if ($st.TouchOn) {
        Draw-Touch $g $st.TouchX $st.TouchY $true
    }

    $canvas.Bitmap.Save("$framesDir\$($st.Name).png", [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $canvas.Bitmap.Dispose()
}

& $ffmpeg -y -loop 1 -t 1.6 -i "$framesDir\c1_s1.png" -c:v libx264 -pix_fmt yuv420p -an -r 25 "$outDir\c1_p1.mp4"
& $ffmpeg -y -loop 1 -t 1.7 -i "$framesDir\c1_s2.png" -c:v libx264 -pix_fmt yuv420p -an -r 25 "$outDir\c1_p2.mp4"
& $ffmpeg -y -loop 1 -t 1.7 -i "$framesDir\c1_s3.png" -c:v libx264 -pix_fmt yuv420p -an -r 25 "$outDir\c1_p3.mp4"

$c1_list = "$outDir\c1_list.txt"
"file '$outDir\c1_p1.mp4'`nfile '$outDir\c1_p2.mp4'`nfile '$outDir\c1_p3.mp4'" | Set-Content $c1_list
& $ffmpeg -y -f concat -safe 0 -i $c1_list -c copy "$clipsDocs\clip1_language_switch.mp4"
Copy-Item "$clipsDocs\clip1_language_switch.mp4" -Destination "$clipsRoot\clip1_language_switch.mp4" -Force

# ==============================================================================
# CLIP 2: AI DIAGNOSIS
# ==============================================================================
Write-Host 'Rendering Clip 2: AI Diagnosis...' -ForegroundColor Yellow

$c2_1 = Create-MobileCanvas
$g = $c2_1.Graphics

$fHead = [System.Drawing.Font]::new('Segoe UI', 42, [System.Drawing.FontStyle]::Bold)
$bDark = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(15, 23, 42))
$g.DrawString('Diagnose Problem', $fHead, $bDark, 50, 140)
$fHead.Dispose()

$fSub = [System.Drawing.Font]::new('Segoe UI', 22, [System.Drawing.FontStyle]::Regular)
$bMuted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(100, 116, 139))
$g.DrawString('Photograph faucet, pipe, switchboard or appliance', $fSub, $bMuted, 50, 205)
$fSub.Dispose()

$photoCard = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(30, 41, 59))
Fill-RRect $g $photoCard 50 280 980 620 40
$photoCard.Dispose()

$pipePen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(148, 163, 184), 48)
$pipePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pipePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawLine($pipePen, 150, 560, 540, 560)
$g.DrawLine($pipePen, 540, 560, 540, 750)
$pipePen.Dispose()

$brass = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(217, 119, 6))
Fill-RRect $g $brass 505 510 70 100 10
$brass.Dispose()

$water = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(56, 189, 248))
$g.FillEllipse($water, 530, 640, 20, 20)
$g.FillEllipse($water, 526, 685, 28, 28)
$water.Dispose()

$tagBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(190, 0, 0, 0))
Fill-RRect $g $tagBg 80 820 340 54 14
$tagBg.Dispose()
$fTag = [System.Drawing.Font]::new('Segoe UI', 20, [System.Drawing.FontStyle]::Bold)
$bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$g.DrawString('demo_water_leak.png', $fTag, $bWhite, 105, 832)
$fTag.Dispose()

$noteBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-RRect $g $noteBg 50 940 980 200 32
$noteBg.Dispose()
$fNoteH = [System.Drawing.Font]::new('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
$g.DrawString('USER PROBLEM DESCRIPTION', $fNoteH, $bMuted, 90, 970)
$fNoteH.Dispose()
$fNoteTxt = [System.Drawing.Font]::new('Segoe UI', 26, [System.Drawing.FontStyle]::Regular)
$rectNote = [System.Drawing.RectangleF]::new(90, 1020, 900, 90)
$g.DrawString('Bathroom tap pipe has continuous water leakage and low pressure under sink.', $fNoteTxt, $bDark, $rectNote)
$fNoteTxt.Dispose()

$btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
Fill-RRect $g $btnBg 50 1750 980 110 32
$btnBg.Dispose()
$fBtn = [System.Drawing.Font]::new('Segoe UI', 32, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Analyze with Gemini AI', $fBtn, $bWhite, 310, 1780)
$fBtn.Dispose()

Draw-Touch $g 540 1805 $true

$c2_1.Bitmap.Save("$framesDir\c2_s1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c2_1.Bitmap.Dispose()

$c2_2 = Create-MobileCanvas
$g = $c2_2.Graphics

$badgeTeal = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(204, 251, 241))
Fill-RRect $g $badgeTeal 50 140 240 60 16
$badgeTeal.Dispose()
$fBadge = [System.Drawing.Font]::new('Segoe UI', 22, [System.Drawing.FontStyle]::Bold)
$bTealTxt = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
$g.DrawString('[OK] 94% Match', $fBadge, $bTealTxt, 75, 153)
$fBadge.Dispose()
$bTealTxt.Dispose()

$badgeAmber = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 243, 199))
Fill-RRect $g $badgeAmber 680 140 350 60 16
$badgeAmber.Dispose()
$fBadgeAmb = [System.Drawing.Font]::new('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
$bAmbTxt = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(180, 83, 9))
$g.DrawString('ACTION RECOMMENDED', $fBadgeAmb, $bAmbTxt, 715, 155)
$fBadgeAmb.Dispose()
$bAmbTxt.Dispose()

$resCard = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-RRect $g $resCard 50 230 980 250 36
$resCard.Dispose()

$fResHead = [System.Drawing.Font]::new('Segoe UI', 36, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Leaking Sink Angle Valve', $fResHead, $bDark, 90, 265)
$fResHead.Dispose()

$tradePill = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
Fill-RRect $g $tradePill 90 350 200 68 16
$tradePill.Dispose()
$fPill = [System.Drawing.Font]::new('Segoe UI', 24, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Plumber', $fPill, $bWhite, 140, 365)
$fPill.Dispose()

$warnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 243, 199))
Fill-RRect $g $warnBg 50 515 980 260 36
$warnBg.Dispose()
$warnPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(245, 158, 11), 3)
Draw-RRect $g $warnPen 50 515 980 260 36
$warnPen.Dispose()

$fWarnHead = [System.Drawing.Font]::new('Segoe UI', 24, [System.Drawing.FontStyle]::Bold)
$bAmber = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(180, 83, 9))
$g.DrawString('[!] EMERGENCY SAFETY PRECAUTION', $fWarnHead, $bAmber, 90, 550)
$fWarnHead.Dispose()
$bAmber.Dispose()

$fWarnTxt = [System.Drawing.Font]::new('Segoe UI', 24, [System.Drawing.FontStyle]::Regular)
$bWarnTxt = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(120, 53, 15))
$rectWarn = [System.Drawing.RectangleF]::new(90, 605, 900, 140)
$g.DrawString('Turn off the main stopcock valve under basin immediately to prevent cabinet wood swelling.', $fWarnTxt, $bWarnTxt, $rectWarn)
$fWarnTxt.Dispose()
$bWarnTxt.Dispose()

$costBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-RRect $g $costBg 50 810 980 240 36
$costBg.Dispose()

$fCostHead = [System.Drawing.Font]::new('Segoe UI', 22, [System.Drawing.FontStyle]::Bold)
$g.DrawString('FAIR LABOR COST ESTIMATE', $fCostHead, $bMuted, 90, 845)
$fCostHead.Dispose()

$fPrice = [System.Drawing.Font]::new('Segoe UI', 56, [System.Drawing.FontStyle]::Bold)
$bPrice = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
$g.DrawString('Rs 250 - Rs 450', $fPrice, $bPrice, 85, 905)
$fPrice.Dispose()
$bPrice.Dispose()

$btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
Fill-RRect $g $btnBg 50 1750 980 110 32
$btnBg.Dispose()
$fBtn = [System.Drawing.Font]::new('Segoe UI', 32, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Book Verified Plumber  ->', $fBtn, $bWhite, 280, 1780)
$fBtn.Dispose()

$c2_2.Bitmap.Save("$framesDir\c2_s2.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c2_2.Bitmap.Dispose()

& $ffmpeg -y -loop 1 -t 2.0 -i "$framesDir\c2_s1.png" -c:v libx264 -pix_fmt yuv420p -an -r 25 "$outDir\c2_p1.mp4"
& $ffmpeg -y -loop 1 -t 3.0 -i "$framesDir\c2_s2.png" -c:v libx264 -pix_fmt yuv420p -an -r 25 "$outDir\c2_p2.mp4"

$c2_list = "$outDir\c2_list.txt"
"file '$outDir\c2_p1.mp4'`nfile '$outDir\c2_p2.mp4'" | Set-Content $c2_list
& $ffmpeg -y -f concat -safe 0 -i $c2_list -c copy "$clipsDocs\clip2_ai_diagnosis.mp4"
Copy-Item "$clipsDocs\clip2_ai_diagnosis.mp4" -Destination "$clipsRoot\clip2_ai_diagnosis.mp4" -Force

# ==============================================================================
# CLIP 3: MAP DISCOVERY
# ==============================================================================
Write-Host 'Rendering Clip 3: Map Discovery...' -ForegroundColor Yellow

$c3_1 = Create-MobileCanvas
$g = $c3_1.Graphics

$mapBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(226, 232, 230))
Fill-RRect $g $mapBg 0 120 1080 1750 0
$mapBg.Dispose()

$roadPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(203, 213, 225), 36)
$g.DrawLine($roadPen, 0, 450, 1080, 580)
$g.DrawLine($roadPen, 320, 120, 420, 1870)
$g.DrawLine($roadPen, 760, 120, 720, 1870)
$g.DrawLine($roadPen, 0, 1200, 1080, 1100)
$roadPen.Dispose()

$park = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(198, 246, 213))
Fill-RRect $g $park 380 600 300 240 30
$park.Dispose()

$pills = @(
    @{ T = 'All (9)'; Active = $false; X = 50 },
    @{ T = 'Services (4)'; Active = $true; X = 260 },
    @{ T = 'Places (3)'; Active = $false; X = 540 },
    @{ T = 'Shops (2)'; Active = $false; X = 790 }
)
foreach ($pl in $pills) {
    $pBgCol = if ($pl.Active) { [System.Drawing.Color]::FromArgb(13, 148, 136) } else { [System.Drawing.Color]::White }
    $pBg = [System.Drawing.SolidBrush]::new($pBgCol)
    Fill-RRect $g $pBg $pl.X 160 210 74 22
    $pBg.Dispose()

    $fPill = [System.Drawing.Font]::new('Segoe UI', 24, [System.Drawing.FontStyle]::Bold)
    $pTxtCol = if ($pl.Active) { [System.Drawing.Color]::White } else { [System.Drawing.Color]::FromArgb(71, 85, 105) }
    $bPTxt = [System.Drawing.SolidBrush]::new($pTxtCol)
    $g.DrawString($pl.T, $fPill, $bPTxt, ($pl.X + 28), 180)
    $fPill.Dispose()
    $bPTxt.Dispose()
}

$pulse = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(60, 59, 130, 246))
$g.FillEllipse($pulse, 450, 850, 180, 180)
$pulse.Dispose()
$dot = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(37, 99, 235))
$g.FillEllipse($dot, 510, 910, 60, 60)
$dot.Dispose()

$mPin = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
$g.FillEllipse($mPin, 480, 640, 110, 110)
$mPin.Dispose()
$fWrench = [System.Drawing.Font]::new('Segoe UI', 32, [System.Drawing.FontStyle]::Bold)
$bWhite = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
$g.DrawString('SVC', $fWrench, $bWhite, 500, 665)
$fWrench.Dispose()

$cardBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-RRect $g $cardBg 50 1360 980 470 44
$cardBg.Dispose()

$fName = [System.Drawing.Font]::new('Segoe UI', 36, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Pawar Plumbing & Sanitary', $fName, $bDark, 95, 1400)
$fName.Dispose()

$fRating = [System.Drawing.Font]::new('Segoe UI', 26, [System.Drawing.FontStyle]::Bold)
$bStar = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(217, 119, 6))
$g.DrawString('* 4.6 (28 reviews) - 1.2 km away', $fRating, $bStar, 95, 1470)
$fRating.Dispose()
$bStar.Dispose()

$fAddr = [System.Drawing.Font]::new('Segoe UI', 22, [System.Drawing.FontStyle]::Regular)
$g.DrawString('JM Road, Deccan Gymkhana, Pune', $fAddr, $bMuted, 95, 1530)
$fAddr.Dispose()

$bCall = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(13, 148, 136))
Fill-RRect $g $bCall 95 1620 420 120 28
$bCall.Dispose()
$fBtnSmall = [System.Drawing.Font]::new('Segoe UI', 28, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Call Provider', $fBtnSmall, $bWhite, 195, 1655)

$bDir = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(241, 245, 249))
Fill-RRect $g $bDir 555 1620 420 120 28
$bDir.Dispose()
$g.DrawString('Directions', $fBtnSmall, $bDark, 680, 1655)
$fBtnSmall.Dispose()

Draw-Touch $g 540 700 $true

$c3_1.Bitmap.Save("$framesDir\c3_s1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c3_1.Bitmap.Dispose()

& $ffmpeg -y -loop 1 -t 5.0 -i "$framesDir\c3_s1.png" -c:v libx264 -pix_fmt yuv420p -an -r 25 "$clipsDocs\clip3_map_discovery.mp4"
Copy-Item "$clipsDocs\clip3_map_discovery.mp4" -Destination "$clipsRoot\clip3_map_discovery.mp4" -Force

# ==============================================================================
# CLIP 4: PRIVACY FIREWALL & LEAD UNLOCK
# ==============================================================================
Write-Host 'Rendering Clip 4: Privacy Quarantine & Lead Unlock...' -ForegroundColor Yellow

$c4_1 = Create-MobileCanvas
$g = $c4_1.Graphics

$fHead = [System.Drawing.Font]::new('Segoe UI', 42, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Incoming Service Lead', $fHead, $bDark, 50, 140)
$fHead.Dispose()

$leadCard = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-RRect $g $leadCard 50 240 980 290 36
$leadCard.Dispose()

$fTitle = [System.Drawing.Font]::new('Segoe UI', 34, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Bathroom Pipeline Water Leakage', $fTitle, $bDark, 95, 280)
$fTitle.Dispose()

$fArea = [System.Drawing.Font]::new('Segoe UI', 26, [System.Drawing.FontStyle]::Regular)
$g.DrawString('Area: Model Colony, Pune (1.2 km away)', $fArea, $bMuted, 95, 360)
$fArea.Dispose()

$privBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(238, 242, 255))
Fill-RRect $g $privBg 50 580 980 300 36
$privBg.Dispose()
$privPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(99, 102, 241), 3)
Draw-RRect $g $privPen 50 580 980 300 36
$privPen.Dispose()

$fPrivH = [System.Drawing.Font]::new('Segoe UI', 24, [System.Drawing.FontStyle]::Bold)
$bInd = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(67, 56, 202))
$g.DrawString('[LOCK]  ZERO-LEAKAGE PRIVACY QUARANTINE', $fPrivH, $bInd, 95, 620)
$fPrivH.Dispose()
$bInd.Dispose()

$fPrivT = [System.Drawing.Font]::new('Segoe UI', 24, [System.Drawing.FontStyle]::Regular)
$bIndTxt = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(49, 46, 129))
$rectPriv = [System.Drawing.RectangleF]::new(95, 690, 880, 140)
$g.DrawString('Customer verified phone number and door address unlock only after you accept the lead with credits.', $fPrivT, $bIndTxt, $rectPriv)
$fPrivT.Dispose()
$bIndTxt.Dispose()

$feeBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-RRect $g $feeBg 50 930 980 150 32
$feeBg.Dispose()
$fFee = [System.Drawing.Font]::new('Segoe UI', 28, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Lead Unlock Fee:  Rs 25 Flat', $fFee, $bDark, 95, 980)
$fFee.Dispose()

$btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(79, 70, 229))
Fill-RRect $g $btnBg 50 1750 980 110 32
$btnBg.Dispose()
$fBtn = [System.Drawing.Font]::new('Segoe UI', 32, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Accept and Pay Rs 25  ->', $fBtn, $bWhite, 290, 1780)
$fBtn.Dispose()

Draw-Touch $g 540 1805 $true

$c4_1.Bitmap.Save("$framesDir\c4_s1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c4_1.Bitmap.Dispose()

$c4_2 = Create-MobileCanvas
$g = $c4_2.Graphics

$unlBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(236, 253, 245))
Fill-RRect $g $unlBg 50 140 980 100 24
$unlBg.Dispose()
$fUnl = [System.Drawing.Font]::new('Segoe UI', 26, [System.Drawing.FontStyle]::Bold)
$bGreen = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(5, 150, 105))
$g.DrawString('[OK]  Customer Phone Unlocked Successfully!', $fUnl, $bGreen, 95, 170)
$fUnl.Dispose()
$bGreen.Dispose()

$contCard = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
Fill-RRect $g $contCard 50 280 980 500 40
$contCard.Dispose()

$avBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(224, 231, 255))
$g.FillEllipse($avBrush, 95, 330, 110, 110)
$avBrush.Dispose()
$fAv = [System.Drawing.Font]::new('Segoe UI', 36, [System.Drawing.FontStyle]::Bold)
$bAv = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(67, 56, 202))
$g.DrawString('MJ', $fAv, $bAv, 120, 355)
$fAv.Dispose()
$bAv.Dispose()

$fCust = [System.Drawing.Font]::new('Segoe UI', 36, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Meera Joshi', $fCust, $bDark, 240, 330)
$fCust.Dispose()

$fPhone = [System.Drawing.Font]::new('Segoe UI', 32, [System.Drawing.FontStyle]::Bold)
$g.DrawString('+91 94220 56789', $fPhone, $bGreen, 240, 390)
$fPhone.Dispose()

$fAddrH = [System.Drawing.Font]::new('Segoe UI', 20, [System.Drawing.FontStyle]::Bold)
$g.DrawString('EXACT DOOR ADDRESS', $fAddrH, $bMuted, 95, 480)
$fAddrH.Dispose()

$fAddrT = [System.Drawing.Font]::new('Segoe UI', 26, [System.Drawing.FontStyle]::Regular)
$g.DrawString('Flat 204, Om Residency, Model Colony, Pune', $fAddrT, $bDark, 95, 520)
$fAddrT.Dispose()

$btnCall = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(5, 150, 105))
Fill-RRect $g $btnCall 95 620 880 110 28
$btnCall.Dispose()
$fCall = [System.Drawing.Font]::new('Segoe UI', 28, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Call Customer Directly', $fCall, $bWhite, 310, 655)
$fCall.Dispose()

$btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(79, 70, 229))
Fill-RRect $g $btnBg 50 1750 980 110 32
$btnBg.Dispose()
$fBtn = [System.Drawing.Font]::new('Segoe UI', 32, [System.Drawing.FontStyle]::Bold)
$g.DrawString('I am on the way  ->', $fBtn, $bWhite, 350, 1780)
$fBtn.Dispose()

$c4_2.Bitmap.Save("$framesDir\c4_s2.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c4_2.Bitmap.Dispose()

& $ffmpeg -y -loop 1 -t 2.0 -i "$framesDir\c4_s1.png" -c:v libx264 -pix_fmt yuv420p -an -r 25 "$outDir\c4_p1.mp4"
& $ffmpeg -y -loop 1 -t 3.0 -i "$framesDir\c4_s2.png" -c:v libx264 -pix_fmt yuv420p -an -r 25 "$outDir\c4_p2.mp4"

$c4_list = "$outDir\c4_list.txt"
"file '$outDir\c4_p1.mp4'`nfile '$outDir\c4_p2.mp4'" | Set-Content $c4_list
& $ffmpeg -y -f concat -safe 0 -i $c4_list -c copy "$clipsDocs\clip4_privacy_firewall.mp4"
Copy-Item "$clipsDocs\clip4_privacy_firewall.mp4" -Destination "$clipsRoot\clip4_privacy_firewall.mp4" -Force

# ==============================================================================
# CLIP 5: 1-TAP EMERGENCY SOS
# ==============================================================================
Write-Host 'Rendering Clip 5: 1-Tap Emergency SOS...' -ForegroundColor Yellow

$c5 = Create-MobileCanvas
$g = $c5.Graphics

$fSosH = [System.Drawing.Font]::new('Segoe UI', 42, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Emergency Assistance', $fSosH, $bDark, 50, 140)
$fSosH.Dispose()

$sosCard = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 38, 38))
Fill-RRect $g $sosCard 50 240 980 360 44
$sosCard.Dispose()

$f112 = [System.Drawing.Font]::new('Segoe UI', 56, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Call 112 Helpline', $f112, $bWhite, 95, 300)
$f112.Dispose()

$f112Sub = [System.Drawing.Font]::new('Segoe UI', 24, [System.Drawing.FontStyle]::Regular)
$bWhiteMuted = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(254, 202, 202))
$g.DrawString('National All-in-One Emergency Response Service', $f112Sub, $bWhiteMuted, 105, 420)
$f112Sub.Dispose()
$bWhiteMuted.Dispose()

$gpsBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(185, 28, 28))
Fill-RRect $g $gpsBg 95 480 780 70 18
$gpsBg.Dispose()
$fGps = [System.Drawing.Font]::new('Segoe UI', 22, [System.Drawing.FontStyle]::Bold)
$g.DrawString('GPS Logged: 18.5204 N, 73.8567 E (Pune)', $fGps, $bWhite, 130, 498)
$fGps.Dispose()

$helplines = @(
    @{ Name = 'Police Control Room'; Num = '100' },
    @{ Name = 'Ambulance Emergency'; Num = '108' },
    @{ Name = 'Fire and Rescue Service'; Num = '101' }
)
$hy = 650
foreach ($h in $helplines) {
    $hBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
    Fill-RRect $g $hBg 50 $hy 980 130 28
    $hBg.Dispose()

    $fHName = [System.Drawing.Font]::new('Segoe UI', 26, [System.Drawing.FontStyle]::Bold)
    $g.DrawString($h.Name, $fHName, $bDark, 95, ($hy + 40))
    $fHName.Dispose()

    $fHNum = [System.Drawing.Font]::new('Segoe UI', 32, [System.Drawing.FontStyle]::Bold)
    $bRed = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 38, 38))
    $g.DrawString($h.Num, $fHNum, $bRed, 860, ($hy + 35))
    $fHNum.Dispose()
    $bRed.Dispose()

    $hy += 160
}

$btnBg = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220, 38, 38))
Fill-RRect $g $btnBg 50 1750 980 110 32
$btnBg.Dispose()
$fBtn = [System.Drawing.Font]::new('Segoe UI', 30, [System.Drawing.FontStyle]::Bold)
$g.DrawString('Alert Urgent Service Providers  ->', $fBtn, $bWhite, 230, 1780)
$fBtn.Dispose()

Draw-Touch $g 540 370 $true

$c5.Bitmap.Save("$framesDir\c5_s1.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$c5.Bitmap.Dispose()

& $ffmpeg -y -loop 1 -t 5.0 -i "$framesDir\c5_s1.png" -c:v libx264 -pix_fmt yuv420p -an -r 25 "$clipsDocs\clip5_emergency_sos.mp4"
Copy-Item "$clipsDocs\clip5_emergency_sos.mp4" -Destination "$clipsRoot\clip5_emergency_sos.mp4" -Force

# 25-Second Clean Montage
Write-Host '>>> Creating 25-Second Clean Montage...' -ForegroundColor Cyan
$cleanMontageList = "$outDir\montage_list.txt"
"file '$clipsDocs\clip1_language_switch.mp4'`nfile '$clipsDocs\clip2_ai_diagnosis.mp4'`nfile '$clipsDocs\clip3_map_discovery.mp4'`nfile '$clipsDocs\clip4_privacy_firewall.mp4'`nfile '$clipsDocs\clip5_emergency_sos.mp4'" | Set-Content $cleanMontageList

$finalMontageDocs = "$clipsDocs\localink_all_5_features_clean.mp4"
$finalMontageRoot = "$clipsRoot\localink_all_5_features_clean.mp4"
& $ffmpeg -y -f concat -safe 0 -i $cleanMontageList -c copy $finalMontageDocs
Copy-Item $finalMontageDocs -Destination $finalMontageRoot -Force

Write-Host '>>> ALL 5 CLEAN CLIPS SUCCESSFULLY GENERATED!' -ForegroundColor Green
Write-Host "   1. $clipsRoot\clip1_language_switch.mp4 (5s)" -ForegroundColor Green
Write-Host "   2. $clipsRoot\clip2_ai_diagnosis.mp4 (5s)" -ForegroundColor Green
Write-Host "   3. $clipsRoot\clip3_map_discovery.mp4 (5s)" -ForegroundColor Green
Write-Host "   4. $clipsRoot\clip4_privacy_firewall.mp4 (5s)" -ForegroundColor Green
Write-Host "   5. $clipsRoot\clip5_emergency_sos.mp4 (5s)" -ForegroundColor Green
Write-Host "   6. $clipsRoot\localink_all_5_features_clean.mp4 (25s)" -ForegroundColor Green
