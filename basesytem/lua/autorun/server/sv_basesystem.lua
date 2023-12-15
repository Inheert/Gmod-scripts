include( 'autorun/sh_basesystem.lua');

concommand.Add("bbsystem_create", function (ply)
    fire_camp = ents.Create("bsystem_firecamp")
    fire_camp:SetPos(ply:GetPos())
    fire_camp:Spawn()
    print(tostring(fire_camp.PrintName))
end)
