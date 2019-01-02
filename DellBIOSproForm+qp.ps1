
$ScriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Restart-PowerShell-Elevated
{
$Script = $ScriptFolder + "\DellBIOSproForm+qp.ps1"
$ConfirmPreference = “None”
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = " -ExecutionPolicy UnRestricted  & '" + $Script + "'" 
Start-Process "$psHome\powershell.exe" -Verb "runAs" -ArgumentList $arguments
Break
}

}
Set-Alias -Name rpe -Value Restart-PowerShell-Elevated

rpe

$ScriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ScriptFolder

Function  UnblockComponents 
        {
         dir $ScriptFolder | Unblock-File 
        }



Function InstallDellModules 
        {
         Install-Module -Name DellBIOSProvider -RequiredVersion 2.0.0 ;
         $FileName = $ScriptFolder + "\" + "Systems-Management_Application_G25RF_WN_8.2.0_A00" ;
         Invoke-Command  -ScriptBlock {
                                       Start-Process $FileName  -ArgumentList '/s' -Wait 
                                      }
         Import-Module DellBIOSProvider  ;
         Write-Host "OMCI Modules installed" ;
        }

Function ModifyBIOSvalues 
        {
         cd DellSmbios:\PowerManagement
         $dir = dir
         foreach ($a in $dir)
                {
                 if ($a.Attribute -eq 'BlockSleep' -and $a.CurrentValue -ne "Enabled" )
                   {
                    $listBox1.Items.Add($a.Attribute + " is " + $a.CurrentValue + ".Modifying to enabled...");
                    Write-Host $a.Attribute " is " $a.CurrentValue ".Modifying to enabled...";
                    Set-Item -Path DellSmbios:\PowerManagement\BlockSleep "Enabled";
                   } 
                 if ($a.Attribute -eq 'DeepSleepCtrl' -and $a.CurrentValue -ne "Disabled" )
                   {
                    $listBox1.Items.Add($a.Attribute + " is " + $a.CurrentValue + ".Modifying to disabled...");
                    Write-Host $a.Attribute " is " $a.CurrentValue ".Modifying to disabled...";
                    Set-Item -Path DellSmbios:\PowerManagement\DeepSleepCtrl "Disabled" ;
                   }
                 if ($a.Attribute -eq 'BlockSleep' -and $a.CurrentValue -eq "Enabled" )
                   {
                    $listBox1.Items.Add($a.Attribute + " is " + $a.CurrentValue);
                    Write-Host $a.Attribute " is " $a.CurrentValue "."    ;                
                   } 
                 if ($a.Attribute -eq 'DeepSleepCtrl' -and $a.CurrentValue -eq "Disabled" )
                   {
                    $listBox1.Items.Add($a.Attribute + " is " + $a.CurrentValue);
                    Write-Host $a.Attribute " is " $a.CurrentValue "."
                   }
                }
        }
     
          
      
Function SetTimeZone 
        {          
         $Global:TimeZone = (Get-TimeZone).Id
         if ($TimeZone -ne "Central European Standard Time" )
           {
            Set-TimeZone -Name "Central European Standard Time" -Verbose
            $TimeZone = (Get-TimeZone).Id
            Write-Output "Current Timezone is: $TimeZone";
            $listBox1.Items.Add("Current Timezone is:" + $TimeZone);
           }
         else
         {
          Write-Output "Current Timezone is: $TimeZone";
          $listBox1.Items.Add("Current Timezone is:" + $TimeZone);
         }
        }
Function UpdateBios 
        {
         $Model = $((Get-WmiObject -Class Win32_ComputerSystem).Model).Trim()     
         $BIOSVersion = (Get-WmiObject -Namespace root\DCIM\SYSMAN -Class DCIM_BIOSElement).Version


         if ($Model -eq "OptiPlex 7050")
         {          
          if ($BIOSVersion -ne '1.11.0' )
           {
             $FileName = $ScriptFolder + "\" + "OptiPlex_7050_1.11.0.exe"
             Invoke-Command  -ScriptBlock {
                                          Start-Process $FileName  -ArgumentList '/s /r' -Wait 
                                         }
            $BIOSVersion = (Get-WmiObject -Namespace root\DCIM\SYSMAN -Class DCIM_BIOSElement).Version
            Write-Output "Current BIOS version: $BIOSVersion "
            $listBox1.Items.Add("Current BIOS version:" + $BIOSVersion );
           }
           else
           {
            Write-Output "Current BIOS version: $BIOSVersion.No need to update "
            $listBox1.Items.Add("Current BIOS version:" + $BIOSVersion + ".No need to update ");
           }
         }
         if ($Model -eq "OptiPlex 3060")
         {          
          if ($BIOSVersion -ne '1.2.22' )
           {
            $FileName = $ScriptFolder + "\" + "OptiPlex_3060_1.2.22.exe"
            Invoke-Command  -ScriptBlock {
                                          Start-Process $FileName  -ArgumentList '/s /r' -Wait 
                                         }
            $BIOSVersion = (Get-WmiObject -Namespace root\DCIM\SYSMAN -Class DCIM_BIOSElement).Version
            Write-Output "Current BIOS version: $BIOSVersion "
            $listBox1.Items.Add("Current BIOS version:" + $BIOSVersion );
           }
           else
           {
            Write-Output "Current BIOS version: $BIOSVersion.No need to update "
            $listBox1.Items.Add("Current BIOS version:" + $BIOSVersion + ".No need to update ");
           }
         }
       }
Function InstallCitrix 
        {
         $FileName = $ScriptFolder + "\" + "CitrixReceiver.exe"
         Invoke-Command  -ScriptBlock {
                                       Start-Process $FileName  -ArgumentList '/silent' -Wait 
                                      }
         if ((Is-Installed("Citrix")) -eq $true )
            {
              Write-Output "Citrix is installed"
              $listBox1.Items.Add("Citrix is installed");
            }
        }
Function Install-SSL-Vpn 
        {
         $FileName = $ScriptFolder + "\" + "SslvpnClient.exe"
         Invoke-Command  -ScriptBlock {
                                       Start-Process $FileName  -ArgumentList '/silent /verysilent' -Wait 
                                      }
         if ((Is-Installed("FortiClient")) -eq $true )
            {
              Write-Output "FortiClient is installed"
              $listBox1.Items.Add("FortiClient is installed");
            }
        }
Function InstallAmazon 
        {
        
         $FileName = $ScriptFolder + "\" + "Amazon+WorkSpaces.msi"
         $FileName
         Invoke-Command  -ScriptBlock {
                                       Start-Process -FilePath msiexec -verb runas -ArgumentList /i, $FileName, /qn -Wait
                                      }
         if ((Is-Installed("Amazon")) -eq $true )
            {
              Write-Output "Amazon is installed"
              $listBox1.Items.Add("Amazon is installed");
            }

        }
        
Function InstallVMware
        {
         $FileName = $ScriptFolder + "\" + "VMware-Horizon-Client-4.7.0-7395453.exe"
         Invoke-Command  -ScriptBlock {
                                       Start-Process $FileName  -ArgumentList '/s /norestart' -Wait 
                                      }
        if (Is-Installed("VMware") -eq $true )
            {
              Write-Output "VMware is installed"
              $listBox1.Items.Add("VMware is installed");
            }
        }
Function InstallChrome 
        {
         if ((Is-Installed("Chrome")) -eq $false )
            {
             $FileName = $ScriptFolder + "\" + "ChromeSetup.exe"
             Invoke-Command  -ScriptBlock {
                                          Start-Process $FileName  -ArgumentList '/silent /install' -Wait 
                                         }
            }

            if (Is-Installed("Chrome") -eq $true )
            {
              Write-Output "Chrome is installed"
              $listBox1.Items.Add("Chrome is installed");
            }
        }
Function Install-QP 
        {
         if ((Is-Installed("QuikPop+")) -eq $false )
            {
             $FileName = $ScriptFolder + "\" + "InstallAGC_conditional.ps1" ;              
             $arguments1 = " -ExecutionPolicy UnRestricted & '" + $FileName + "'" 
             Start-Process "$psHome\powershell.exe" -Verb "runAs" -ArgumentList $arguments1 -Wait
             }
         
          if (Is-Installed("QuikPop+") -eq $true )
            {
             Write-Output "Quickpop is installed"
             $listBox1.Items.Add("Quickpop is installed");
            }
        
        }
Set-Alias -Name iq -Value Install-QP ;

Function Install-Verint 
        {
         if ((Is-Installed("Impact 360 Desktop Applications")) -eq $false )
            {
             $FileName = $ScriptFolder + "\" + "InstallVerint_conditional.ps1" ;              
             $arguments1 = " -ExecutionPolicy UnRestricted & '" + $FileName + "'" 
             Start-Process "$psHome\powershell.exe" -Verb "runAs" -ArgumentList $arguments1 -Wait
             }
         
          if (Is-Installed("Impact 360 Desktop Applications") -eq $true )
            {
             Write-Output "Impact 360 Desktop Applications is installed"
             $listBox1.Items.Add("Impact 360 Desktop Applications is installed");
            }
        
        }
Set-Alias -Name iv -Value Install-Verint ;
             

 function Is-Installed( $program ) {
    
    $x86 = ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    $x64 = ((Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    return $x86 -or $x64;
}       





UnblockComponents
InstallDellModules

$Global:project = "" #InputProjectName


function GenerateForm {

[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

$form1 = New-Object System.Windows.Forms.Form 
$button1 = New-Object System.Windows.Forms.Button
$listBox1 = New-Object System.Windows.Forms.ListBox
$DropDownBox = New-Object System.Windows.Forms.ComboBox
$checkBox10 = New-Object System.Windows.Forms.CheckBox
$checkBox9 = New-Object System.Windows.Forms.CheckBox
$checkBox8 = New-Object System.Windows.Forms.CheckBox
$checkBox7 = New-Object System.Windows.Forms.CheckBox
$checkBox6 = New-Object System.Windows.Forms.CheckBox
$checkBox5 = New-Object System.Windows.Forms.CheckBox
$checkBox4 = New-Object System.Windows.Forms.CheckBox
$checkBox3 = New-Object System.Windows.Forms.CheckBox
$checkBox2 = New-Object System.Windows.Forms.CheckBox
$checkBox1 = New-Object System.Windows.Forms.CheckBox
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState


#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------

$handler_button1_Click= 
{
    #$listBox1.Items.Clear();    

    if ($checkBox1.Checked)
      {
          $listBox1.Items.Add( "Checkbox 1 is checked"  ) ;
          InstallChrome    ;  
      }

    if ($checkBox2.Checked)
      {
          $listBox1.Items.Add( "Checkbox 2 is checked"  ) ;
          InstallCitrix ;
      }

    if ($checkBox3.Checked)    
      {  
          $listBox1.Items.Add( "Checkbox 3 is checked"  ) ;
          InstallVMware ;
                
      }

    if ($checkBox4.Checked)
     {
          $listBox1.Items.Add( "Checkbox 4 is checked"  ) ;
          SetTimeZone ;
      }

    if ($checkBox5.Checked)
     {
          $listBox1.Items.Add( "Checkbox 5 is checked"  ) ;
          ModifyBIOSvalues ;

     }

    if ($checkBox6.Checked)
    {
         $listBox1.Items.Add( "Checkbox 6 is checked"  );
         InstallAmazon ;
    }
    if ($checkBox7.Checked)
    {
         $listBox1.Items.Add( "Checkbox 7 is checked"  );
         iq ;
    }
    if ($checkBox8.Checked)
    {
         $listBox1.Items.Add( "Checkbox 8 is checked"  );
         iv ;
    }
    if ($checkBox9.Checked)
    {
         $listBox1.Items.Add( "Checkbox 9 is checked"  );
         Install-SSL-Vpn ;
    }
    if ($checkBox10.Checked)
    {
         $listBox1.Items.Add( "Checkbox 10 is checked"  );
         UpdateBios ;
    }

    if ( !$checkBox1.Checked -and !$checkBox2.Checked -and !$checkBox3.Checked -and !$checkBox4.Checked -and !$checkBox5.Checked -and !$checkBox6.Checked -and !$checkBox7.Checked -and !$checkBox8.Checked -and !$checkBox9.Checked)
     {   $listBox1.Items.Add("No CheckBox selected....")} 
}

$handler_DropDownBox_SelectedIndexChanged=
{

       if ($DropDownBox.Text.Length -gt 0)
    {
        $listBox1.Items.Add($DropDownBox.Text + " was selected");
        $Global:project = $DropDownBox.Text ;
        

        if ($Global:project -eq "Alstom")
  {
   $checkBox1.Checked = $true ;
   $checkBox2.Checked = $true ;
   $checkBox3.Checked = $false ;
   $checkBox4.Checked = $true ;
   $checkBox5.Checked = $true ;
   $checkBox6.Checked = $false ;
   $checkBox7.Checked = $false ;
   $checkBox8.Checked = $false ;
   $checkBox9.Checked = $false ;
   $checkBox10.Checked = $true ;
   }

        if ($Global:project -eq "BD")
  {
   $checkBox1.Checked = $true ;
   $checkBox2.Checked = $true ;
   $checkBox3.Checked = $true ;
   $checkBox4.Checked = $true ;
   $checkBox5.Checked = $true ;
   $checkBox6.Checked = $false ;
   $checkBox7.Checked = $false ;
   $checkBox8.Checked = $false ;
   $checkBox9.Checked = $false ;
   $checkBox10.Checked = $true ;
   }
 
   if ($Global:project -eq "DB")
  {
   $checkBox1.Checked = $true ;
   $checkBox2.Checked = $true ;
   $checkBox3.Checked = $false ;
   $checkBox4.Checked = $true ;
   $checkBox5.Checked = $true ;
   $checkBox6.Checked = $false ;
   $checkBox7.Checked = $true ;
   $checkBox8.Checked = $false ;
   $checkBox9.Checked = $false ;
   $checkBox10.Checked = $true ;
   }
   if ($Global:project -eq "Havi")
  {
   $checkBox1.Checked = $true ;
   $checkBox2.Checked = $true ;
   $checkBox3.Checked = $false ;
   $checkBox4.Checked = $true ;
   $checkBox5.Checked = $true ;
   $checkBox6.Checked = $false ;
   $checkBox7.Checked = $false ;
   $checkBox8.Checked = $false ;
   $checkBox9.Checked = $false ;
   $checkBox10.Checked = $true ;
   }
     if ($Global:project -eq "Sasol")
  {
   $checkBox1.Checked = $true ;
   $checkBox2.Checked = $true ;
   $checkBox3.Checked = $false ;
   $checkBox4.Checked = $true ;
   $checkBox5.Checked = $true ;
   $checkBox6.Checked = $false ;
   $checkBox7.Checked = $false ;
   $checkBox8.Checked = $false ;
   $checkBox9.Checked = $true ;
   $checkBox10.Checked = $true ;
   }
  }  
 }


$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
    $form1.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#region Generated Form Code
$form1.Text = "Installator"
$form1.Name = "Installator"
$form1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 450
$System_Drawing_Size.Height = 400
$form1.ClientSize = $System_Drawing_Size

$button1.TabIndex = 4
$button1.Name = "button1"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 75
$System_Drawing_Size.Height = 23
$button1.Size = $System_Drawing_Size
$button1.UseVisualStyleBackColor = $True

$button1.Text = "Run Script"

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 360
$button1.Location = $System_Drawing_Point
$button1.DataBindings.DefaultDataSourceUpdateMode = 0
$button1.add_Click($handler_button1_Click)

$form1.Controls.Add($button1)

$listBox1.FormattingEnabled = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 301
$System_Drawing_Size.Height = 250
$listBox1.Size = $System_Drawing_Size
$listBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$listBox1.Name = "listBox1"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 147
$System_Drawing_Point.Y = 13
$listBox1.Location = $System_Drawing_Point
$listBox1.TabIndex = 3

$form1.Controls.Add($listBox1)

$DropDownBox.Location = New-Object System.Drawing.Size(24,329) 
$DropDownBox.Size = New-Object System.Drawing.Size(180,20) 
$DropDownBox.DropDownHeight = 200 


$Projects=@("Alstom","BD","DB" ,"Havi","Sasol")

foreach ($Project in $Projects) {
                      $DropDownBox.Items.Add($Project)
                              }     

$DropDownBox.add_SelectedIndexChanged($handler_DropDownBox_SelectedIndexChanged)
$form1.Controls.Add($DropDownBox)


$checkBox10.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$checkBox10.Size = $System_Drawing_Size
$checkBox10.TabIndex = 11
$checkBox10.Text = "Update BIOS"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 298
$checkBox10.Location = $System_Drawing_Point
$checkBox10.DataBindings.DefaultDataSourceUpdateMode = 0
$checkBox10.Name = "checkBox10"

$form1.Controls.Add($checkBox10)



$checkBox9.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$checkBox9.Size = $System_Drawing_Size
$checkBox9.TabIndex = 10
$checkBox9.Text = "Install SsLVpn"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 267
$checkBox9.Location = $System_Drawing_Point
$checkBox9.DataBindings.DefaultDataSourceUpdateMode = 0
$checkBox9.Name = "checkBox9"

$form1.Controls.Add($checkBox9)

$checkBox8.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$checkBox8.Size = $System_Drawing_Size
$checkBox8.TabIndex = 9
$checkBox8.Text = "Instal Verint"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 235
$checkBox8.Location = $System_Drawing_Point
$checkBox8.DataBindings.DefaultDataSourceUpdateMode = 0
$checkBox8.Name = "checkBox8"

$form1.Controls.Add($checkBox8)




$checkBox7.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$checkBox7.Size = $System_Drawing_Size
$checkBox7.TabIndex = 8
$checkBox7.Text = "Install QP"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 204
$checkBox7.Location = $System_Drawing_Point
$checkBox7.DataBindings.DefaultDataSourceUpdateMode = 0
$checkBox7.Name = "checkBox7"

$form1.Controls.Add($checkBox7)


$checkBox6.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$checkBox6.Size = $System_Drawing_Size
$checkBox6.TabIndex = 7
$checkBox6.Text = "InstallAmazon"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 173
$checkBox6.Location = $System_Drawing_Point
$checkBox6.DataBindings.DefaultDataSourceUpdateMode = 0
$checkBox6.Name = "checkBox6"

$form1.Controls.Add($checkBox6)

$checkBox5.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$checkBox5.Size = $System_Drawing_Size
$checkBox5.TabIndex = 6
$checkBox5.Text = "Modify BIOS"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 137
$checkBox5.Location = $System_Drawing_Point
$checkBox5.DataBindings.DefaultDataSourceUpdateMode = 0
$checkBox5.Name = "checkBox5"

$form1.Controls.Add($checkBox5)

$checkBox4.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$checkBox4.Size = $System_Drawing_Size
$checkBox4.TabIndex = 5
$checkBox4.Text = "Set timezone"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 106
$checkBox4.Location = $System_Drawing_Point
$checkBox4.DataBindings.DefaultDataSourceUpdateMode = 0
$checkBox4.Name = "checkBox4"

$form1.Controls.Add($checkBox4)

$checkBox3.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$checkBox3.Size = $System_Drawing_Size
$checkBox3.TabIndex = 2
$checkBox3.Text = "InstallVM"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 75
$checkBox3.Location = $System_Drawing_Point
$checkBox3.DataBindings.DefaultDataSourceUpdateMode = 0
$checkBox3.Name = "checkBox3"

$form1.Controls.Add($checkBox3)


$checkBox2.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$checkBox2.Size = $System_Drawing_Size
$checkBox2.TabIndex = 1
$checkBox2.Text = "Install Citrix"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 44
$checkBox2.Location = $System_Drawing_Point
$checkBox2.DataBindings.DefaultDataSourceUpdateMode = 0
$checkBox2.Name = "checkBox2"

$form1.Controls.Add($checkBox2)


$checkBox1.UseVisualStyleBackColor = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 104
$System_Drawing_Size.Height = 24
$checkBox1.Size = $System_Drawing_Size
$checkBox1.TabIndex = 0
$checkBox1.Text = "Install Chrome"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 27
$System_Drawing_Point.Y = 13
$checkBox1.Location = $System_Drawing_Point
$checkBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$checkBox1.Name = "checkBox1"

$form1.Controls.Add($checkBox1)


#Save the initial state of the form
$InitialFormWindowState = $form1.WindowState
#Init the OnLoad event to correct the initial state of the form
$form1.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$form1.ShowDialog()| Out-Null

} #End Function

#Call the Function
GenerateForm
