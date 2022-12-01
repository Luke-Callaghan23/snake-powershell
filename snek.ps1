$frames = 0



if (-not $hiScore) {
    $hiScore = 0
}


function Write-Board ($snek, $fruit) {


    # draw snake head
    $sned = if ($snek.living) { "O" } else { "X" }
    [Console]::SetCursorPosition($snek.x + $xoff, $snek.y + $yoff)
    [Console]::Write($sned)

    # Draw new tail piece
    $tailPiece = $snek.tail[$snek.tail.Length - 1]
    $x = $tailPiece.x
    $y = $tailPiece.y
    $tailDirection = $tailPiece.tailDirection

    [Console]::SetCursorPosition($x + $xoff, $y + $yoff)
    [Console]::Write($tailDirection)

    # Erase old tail piece
    $eraseIndex = $snek.tail.Length -1- $snek.tailLength
    $tailPieceDelete = $snek.tail[$eraseIndex]
    $x = $tailPieceDelete.x
    $y = $tailPieceDelete.y
    $tailDirection = $tailPieceDelete.tailDirection

    if ($eraseIndex -ne -1) {
        [Console]::SetCursorPosition($x + $xoff, $y + $yoff)
        [Console]::Write(" ")
    }

    
    # draw fruit
    $x = $fruit.x
    $y = $fruit.y

    [Console]::SetCursorPosition($x + $xoff, $y + $yoff)
    [Console]::Write("A")

    # draw score
    [Console]::SetCursorPosition(0,0)
    [Console]::Write("Score: ")
    [Console]::Write($score)

    # draw hi score
    [Console]::SetCursorPosition(70,0)
    [Console]::Write("Hi Score: ")
    [Console]::Write($hiScore)
}

function Write-Menu ($type) {
    $menuWidth = 40
    $menuHeight = 10
    $menuXOff = $xoff + $menuWidth / 2 - 1
    $menuYOff = $yoff + $menuHeight / 2 - 2

    [Console]::SetCursorPosition($menuXOff, $menuYOff)
    [Console]::Write("\")
    [Console]::Write("|" * ($menuWidth + 2))
    [Console]::Write("/")

    for ($row = 1; $row -lt $menuHeight; $row += 1) {
        [Console]::SetCursorPosition($menuXOff, $menuYOff + $row)
        [Console]::Write("=")
        [Console]::Write(" " * ($menuWidth + 3))
        [Console]::Write("=")
    }

    [Console]::SetCursorPosition($menuXOff, $menuYOff + $menuHeight)
    [Console]::Write("/")
    [Console]::Write("|" * ($menuWidth + 2))
    [Console]::Write("\")



    # Write menu header
    $message = if ($type -eq $states.died) {
        "YOU DIED!"
    }
    elseif ($type -eq $states.start) {
        "M E N U"
    }
    elseif ($type -eq $states.help) {  
        "H E L P"
    }

    [Console]::SetCursorPosition($menuXOff + ($menuWidth / 2) - $message.Length / 3, $menuYOff + 1)
    [Console]::Write($message)
    if ($type -ne $states.help) {
    
        $playOption = if ($type -eq $states.died) {
            "Play Again"
        }
        else {
            "Play"
        }
    
        # Write menu options
        [Console]::SetCursorPosition($menuXOff + ($menuWidth / 3), $menuYOff + 3)
        [Console]::Write($playOption)
        [Console]::SetCursorPosition($menuXOff + ($menuWidth / 3), $menuYOff + 5)
        [Console]::Write("Help")
        [Console]::SetCursorPosition($menuXOff + ($menuWidth / 3), $menuYOff + 7)
        [Console]::Write("Quit")
    }
    else {
        [Console]::SetCursorPosition($menuXOff + ($menuWidth / 4), $menuYOff + 3)
        [Console]::Write("Arrow/WASD keys to move around")
        [Console]::SetCursorPosition($menuXOff + ($menuWidth / 4), $menuYOff + 5)
        [Console]::Write("'q' to quit")
        [Console]::SetCursorPosition($menuXOff + ($menuWidth / 4), $menuYOff + 7)
        [Console]::Write("'r' to restart")
    }

}

function Write-OverMenu ($type) {

}

function Write-Cursor {
    $menuWidth = 40
    $menuHeight = 10
    $menuXOff = $xoff + $menuWidth / 2 - 1
    $menuYOff = $yoff + $menuHeight / 2 - 2
    [Console]::SetCursorPosition($menuXOff + ($menuWidth / 3) - 5, $menuYOff + 3)
    [Console]::Write(" ")
    [Console]::SetCursorPosition($menuXOff + ($menuWidth / 3) - 5, $menuYOff + 5)
    [Console]::Write(" ")
    [Console]::SetCursorPosition($menuXOff + ($menuWidth / 3) - 5, $menuYOff + 7)
    [Console]::Write(" ")

    [Console]::SetCursorPosition($menuXOff + ($menuWidth / 3) - 5, $menuYOff + 3 + ($global:selectedMenu * 2))
    [Console]::Write(" ")
}

function New-Fruit ($snek) {
    $bad = $true
    while ($bad) {
        $x = Get-Random -Minimum 0 -Maximum $width
        $y = Get-Random -Minimum 0 -Maximum $height
        
        $bad = $false
        $tail = $snek.tail
        $tailLength = $snek.tailLength
        for ($off = $tail.Length - $tailLength; $off -lt $tail.Length; $off += 1) {
            $tailPiece = $tail[$off]
            $tpx = $tailPiece.x
            $tpy = $tailPiece.y
            if ($snex -eq $tpx -and $sney -eq $tpy) {
                $bad = $true
                break
            }
        }
    }
    return [PSCustomObject]@{
        x = $x
        y = $y
    }
}


function Get-Collision ($snek, $fruit) {
    $snex = $snek.x
    $sney = $snek.y


    # bounds checks
    if ($snex -lt 0 -or $snex -gt $width) {
        return 'wall'
    }
    if ($sney -lt 0 -or $sney -ge $height) {
        return 'wall'
    }

    # snek check
    $tail = $snek.tail
    $tailLength = $snek.tailLength
    for ($off = $tail.Length - $tailLength; $off -lt $tail.Length; $off += 1) {
        $tailPiece = $tail[$off]
        $tpx = $tailPiece.x
        $tpy = $tailPiece.y
        if ($snex -eq $tpx -and $sney -eq $tpy) {
            return 'tail'
        }
    }


    # fruit check
    $fruitx = $fruit.x
    $fruity = $fruit.y
    if ($snex -eq $fruitx -and $sney -eq $fruity) {
        return 'fruit'
    }

    return $null
}


$global:heightStep = 0
function Tick-Snek ($snek) {


    $nextx = $snek.x
    $nexty = $snek.y

    if ($global:dir -eq 'up') {
        # if (($global:heightStep % 2) -eq 0) {
            $nexty = $snek.y - 1
        # }
        # $global:heightStep += 1
    }
    elseif ($global:dir -eq 'down') {
        # if (($global:heightStep % 2) -eq 0) {
            $nexty = $snek.y + 1
        # }
        # $global:heightStep = $global:heightStep + 1
    }
    elseif ($global:dir -eq 'left') {
        $nextx = $snek.x - 1
    }
    elseif ($global:dir -eq 'right') {
        $nextx = $snek.x + 1
    }


    $tail = $snek.tail
    $end = $snek.tail[$tail.Length - 1]

    $tailDirection = if ($global:dir -ne $snek.dir) {
        if ($snek.dir -eq 'up') {
            if ($global:dir -eq 'left') {
                '\'
            }
            elseif ($global:dir -eq 'right') {
                '/'
            }
        }
        elseif ($snek.dir -eq 'down') {
            if ($global:dir -eq 'left') {
                '/'
            }
            elseif ($global:dir -eq 'right') {
                '\'
            }
        }
        elseif ($snek.dir -eq 'left') {
            if ($global:dir -eq 'up') {
                '\'
            }
            elseif ($global:dir -eq 'down') {
                '/'
            }
        }
        elseif ($snek.dir -eq 'right') {
            if ($global:dir -eq 'up') {
                '/'
            }
            elseif ($global:dir -eq 'down') {
                '\'
            }
        }
    }
    else {
        if ($snek.dir -eq 'up' -or $snek.dir -eq 'down') {
            '|'
        }
        elseif ($snek.dir -eq 'left' -or $snek.dir -eq 'right') {
            '-'
        }
    }

    
    $newPiece = if (-not ($snek.x -eq $nextx -and $snek.y -eq $nexty)) {
        [PSCustomObject]@{
            x = $snek.x
            y = $snek.y
            tailDirection = $tailDirection
        }
    }
    else {
        $null
    }

    if ($null -ne $newPiece) {
        $tail += $newPiece
    }

    $tailLength = $snek.tailLength
    $growing = $snek.growing
    if ($growing -gt 0) {
        $tailLength += 1
        $growing -= 1
    }
    return [PSCustomObject]@{
        x = $nextx
        y = $nexty
        tail = $tail
        dir = $global:dir
        tailLength = $tailLength
        growing = $growing
        living = $true
    }
}

function Get-Key ($snek) {
    if ([Console]::KeyAvailable) {
        # read the key, and consume it so it won't
        # be echoed to the console:
        $keyInfo = [Console]::ReadKey($true)
        
        if ($keyInfo.Key -eq "W" -or $keyInfo.Key -eq "UpArrow") {
            if ($global:dir -eq 'left' -or $global:dir -eq 'right') {
                $global:heightStep = 0
                $global:dir = 'up'
            }
        }
        elseif ($keyInfo.Key -eq "S" -or $keyInfo.Key -eq "DownArrow") {
            if ($global:dir -eq 'left' -or $global:dir -eq 'right') {
                $global:heightStep = 0
                $global:dir = 'down'
            }
        }
        elseif ($keyInfo.Key -eq "A" -or $keyInfo.Key -eq "LeftArrow") {
            if ($global:dir -eq 'up' -or $global:dir -eq 'down') {
                $global:dir = 'left'
            }
        }
        elseif ($keyInfo.Key -eq "D" -or $keyInfo.Key -eq "RightArrow") {
            if ($global:dir -eq 'up' -or $global:dir -eq 'down') {
                $global:dir = 'right'
            }
        }
        elseif ($keyInfo.Key -eq 'Q' -or $keyInfo.Key -eq "q") {
            return $false
        }
        elseif ($keyInfo.Key -eq 'C') {
            Clean-Board $snek
        }
    }
    return $true
}

function Get-MenuKey {
    while (-not [Console]::KeyAvailable) {}

    # read the key, and consume it so it won't
    # be echoed to the console:
    $keyInfo = [Console]::ReadKey($true)
    
    if ($keyInfo.Key -eq "W" -or $keyInfo.Key -eq "UpArrow") {
        $global:selectedMenu -= 1
        if ($global:selectedMenu -eq -1) {
            $global:selectedMenu = $menuOptions - 1
        }
    }
    elseif ($keyInfo.Key -eq "S" -or $keyInfo.Key -eq "DownArrow") {
        $global:selectedMenu = ($global:selectedMenu + 1) % $menuOptions
    }
    elseif ($keyInfo.Key -eq "Q" -or $keyInfo.Key -eq "q") {
        return $states.done
    }
    elseif ($keyInfo.Key -eq 'Enter' -or $keyInfo.Key -eq 'Spacebar') {
        if ($global:selectedMenu -eq 0) {
            return $states.playing
        }
        elseif ($global:selectedMenu -eq 1) {
            return $states.help
        }
        elseif ($global:selectedMenu -eq 2) {
            return $states.done
        }
    }

    return $state
}

function Get-HelpKey {
    while (-not [Console]::KeyAvailable) {}
    [Console]::ReadKey($true)
    return $states.start
}

cls


# Draw border
function Clear-Board {
    [Console]::SetCursorPosition(0,1)
    [Console]::Write("/" + ("-" * ($width + 1)) + "\")
    [Console]::SetCursorPosition(0,($height + 2))
    [Console]::Write("\" + ("-" * ($width + 1)) + "/")

    # clear screen
    for ($row = 0; $row -lt $height; $row++) {
        [Console]::SetCursorPosition(0, $row + 2)
        [Console]::Write("|")
        [Console]::Write(" " * ($width + 1))
        [Console]::Write("|")
    }

    [Console]::SetCursorPosition(35, 0)
    [Console]::Write("~~~S N A K E~~~")

    [Console]::SetCursorPosition(0, $height + $yoff)
    [Console]::Write("'c' to clean up")
}

Clear-Board

function Clean-Board ($snek) {
    Clear-Board

    
    # redraw snek
    $tail = $snek.tail
    $tailLength = $snek.tailLength
    for ($off = $tail.Length - $tailLength; $off -lt $tail.Length; $off += 1) {
        $tailPiece = $tail[$off]
        $tpx = $tailPiece.x
        $tpy = $tailPiece.y
        $tailDirection = $tailPiece.tailDirection
    
        [Console]::SetCursorPosition($tpx + $xoff, $tpy + $yoff)
        [Console]::Write($tailDirection)        
        
    }

    $snex = $snek.x
    $sney = $snek.y

    [Console]::SetCursorPosition($snex + $xoff, $sney + $yoff)
    [Console]::Write("O")

}

$states = [PSCustomObject]@{
    start = 'start'
    playing = 'playing'
    died = 'died'
    help = 'help'
    done = 'done'
}
$state = $states.start


$menuOptions = 3
while ($state -ne $states.done) {

    $global:selectedMenu = 0
    Write-Menu $state
    
    while ($state -eq $states.died -or $state -eq $states.start ) {
        Write-Cursor
        $state = Get-MenuKey
    }
    $global:selectedMenu = 0
    Write-Menu $state

    while ($state -eq $states.help) {
        $state = Get-HelpKey
    }

    $global:dir = 'right'

    $width = 80
    $height = 20
    $xoff = 1
    $yoff = 2

    $snek = [PSCustomObject]@{
        x = 40
        y = 0
        dir = 'left'
        tail = @()
        tailLength = 0
        living = $true
        growing = 5
    }

    $fruit = [PSCustomObject]@{
        x = Get-Random -Minimum 2 -Maximum $width
        y = Get-Random -Minimum 2 -Maximum $height
    }


    $score = 0
    $frames = 0
    while ($state -eq $states.playing) {
        [Console]::SetCursorPosition(0,0)
        
        Write-Board $snek $fruit
        if (-not $snek.living) {
            $state = $states.died
            break
        }
    
        $snek = Tick-Snek $snek
        $collision = Get-Collision -snek $snek -fruit $fruit
    
        $playing = Get-Key $snek
        if (-not $playing) {
            $state = $states.done
        }
    
        if ($collision -eq 'fruit') {
            # bigger tail
            $snek.growing += 5
            # new fruit
            $fruit = New-Fruit $snek
    
            $score += 5
            if ($score -gt $hiScore) {
                $hiScore = $score
            }
        }
        elseif ($collision -eq 'wall' -or $collision -eq 'tail') {
            $snek.living = $false
        }
    
        if ($global:dir -eq 'up' -or $global:dir -eq 'down') {
            start-sleep -Milliseconds 107
        }
        else {
            start-sleep -Milliseconds 47
        }
    
        $frames += 1
    }
}



cls