include( 'autorun/sh_basesystem.lua')

concommand.Add('pute', function (ply)
    BBSYSTEM:PrintSomething()
end)