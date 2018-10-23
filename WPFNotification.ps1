<#
    .SYNOPSIS
    Display a notifcation window

    .DESCRIPTION
    Displays a WPF based window on login (when put in the startup folder) with a bulleted list of tasks for the employee
    to address first thing once shift is started. Click the 'OK' button to close the window

    .NOTES
    *Author - Darrin Britton
    *Use Case - Specific scenario this was created for was to provide a notification window for student employee's at a
    front desk that has a frequent change in shifts.

#>

[cmdletbinding()]
Param()

Add-Type -AssemblyName PresentationFramework

#[convert]::ToBase64String((Get-Content .\logo.png -Encoding byte))
$bytes = @"
    Base64 encoded string content from image - paste here to remove need to external resources.
"@

#Convert base64 encoded string back to image, create image file in users temp folder
$logo = [System.Convert]::FromBase64String($bytes)
Set-Content -Path "$env:TEMP\logo.png" -Value $logo -Encoding Byte


[XML]$Form = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Front Desk Notification" Height="450" Width="800">
    <Grid>
        <TextBox Name="DontForget" HorizontalAlignment="Left" Height="39" Margin="47,32,0,0" TextWrapping="Wrap" Text="Don't forget to:&#xD;&#xA;&#xD;&#xA;" VerticalAlignment="Top" Width="196" TextDecorations="Underline" FontWeight="Bold" BorderThickness="0" FontSize="24"/>
        <TextBox HorizontalAlignment="Left" Height="239" Margin="47,85,0,0" TextWrapping="Wrap" Text="&#xD;&#xA;  &#x25CF; BLAH&#xD;&#xA;&#xD;&#xA;&#xD;&#xA;  &#x25CF; BLAH&#xD;&#xA;&#xD;&#xA;&#xD;&#xA;  &#x25CF; BLAH" VerticalAlignment="Top" Width="524" FontSize="20" BorderThickness="0"/>
        <Button Name="Confirm" Content="OK" HorizontalAlignment="Left" Margin="571,342,0,0" VerticalAlignment="Top" Width="198" Height="39" FontSize="24"/>
        <Image HorizontalAlignment="Left" Height="124" Margin="571,32,0,0" VerticalAlignment="Top" Width="198" Source="$env:TEMP\logo.png"/>
    </Grid>
</Window>
"@

$NR = (New-Object System.Xml.XmlNodeReader $Form)
$Win = [Windows.Markup.XamlReader]::Load( $NR )

$OKButton = $win.FindName("Confirm")

$OKButton.add_click({

    $win.close()

})

#[Void] required to prevent output to console when dialog box is closed
[Void]$Win.ShowDialog()