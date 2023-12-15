include('autorun/sh_utilities.lua')

resource.AddFile( "resource/fonts/Louis George Cafe.ttf" )
resource.AddFile( "resource/fonts/Louis George Cafe Bold.ttf" )

util.AddNetworkString("ClientDisplayMessage")

net.Receive("ClientDisplayMessage", function(len, ply)
    local message = net.ReadTable()
    net.Start('DisplayMessage')
    net.WriteTable(message)
    net.Send(ply)
end)