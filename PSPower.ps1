#Example
#-RemoteHost "192.168.0.55" -user "username" -pass "password" -catlocation "cat /proc/analog/value1"
#.\PSPower.ps1 -RemoteHost "172.20.1.191" -user "ubnt" -pass "ubnt" -catlocation "cat /proc/analog/rms2"
#https://community.ui.com/questions/Current-sensors-and-wiring-codes/1f6d5889-9bce-4d07-a1ae-1f46b12b385b

Param (
        [Parameter(ValueFromPipeline=$true)]
        [String]$user = "username",
        [String]$pass = "password",
        [String]$catlocation = "command",
        [string]$RemoteHost = "HostnameOrIPAddress",
        [string]$Port = "23",
        [int]$WaitTime = 1200
    )

    #Write-Host $Commands[1]
    #Write-Host $Commands
    #Write-Host $RemoteHost
    #exit 0


   #Write-Host $Commands[0]
    #exit 0


    #Attach to the remote device, setup streaming requirements
    $Socket = New-Object System.Net.Sockets.TcpClient($RemoteHost, $Port)
    If ($Socket)
    {   $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        $Buffer = New-Object System.Byte[] 1024 
        $Encoding = New-Object System.Text.AsciiEncoding
        #write-host $user
        #write-host $pass
        #Write-Host $catlocation

        #wait for session to stablize
        Start-Sleep -Milliseconds ($WaitTime*2)
        $Writer.WriteLine($user)
        $Writer.Flush()
        Start-Sleep -Milliseconds $WaitTime
        $Writer.WriteLine($pass)
        $Writer.Flush()
        Start-Sleep -Milliseconds $WaitTime
        $Writer.WriteLine($catlocation)
        $Writer.Flush()

        #Now start issuing the commands
        #ForEach ($Command in $Commands)
        #{   $Writer.WriteLine($Command)
            #Write-Host $Command 
        #    $Writer.Flush()
        #    Start-Sleep -Milliseconds $WaitTime
        #}
        #All commands issued, but since the last command is usually going to be
        #the longest let's wait a little longer for it to finish
        Start-Sleep -Milliseconds ($WaitTime * 4)
        $Result = ""
        #Save all the results
        While($Stream.DataAvailable) 
        {   $Read = $Stream.Read($Buffer, 0, 1024) 
            $Result += ($Encoding.GetString($Buffer, 0, $Read))
        }
        $Socket.Close()
    }
    Else     
    {   $Result = "Unable to connect to host: $($RemoteHost):$Port"
    }

    $next = 0 
    foreach ($line in $Result.Split("`n") ){
        if ($next -eq 1){
            $final= [double]$line
            $far = ($final * 100)

            
            $x=[string]$far+":The Current Value is "+$far+" thanks."
            write-host $x
            
            exit 0
        }

        if ($line.Contains("# cat /proc/")){
            $next = 1
        }

    }


exit 0