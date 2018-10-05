<#
#http://matthewmanela.com/blog/quickly-moving-up-a-directory-tree/
Found this code snippet to quickly navigate up a directory tree - the structure of the code
interested me. Saving for later study.
#>

for ($i = 1; $i -le 5; $i++) {

    $u =  "".PadLeft($i,"u")
    $unum =  "u$i"
    $d =  $u.Replace("u","../")

    Invoke-Expression "function $u { push-location $d }"
    Invoke-Expression "function $unum { push-location $d }"

}