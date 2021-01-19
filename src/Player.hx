import h3d.scene.Scene;
import h3d.scene.Mesh;
import h3d.scene.Object;

class Player
{ 
    var value : Object;
    var turret : Mesh;

    public function new(scene : Scene, x : Int, y : Int)
    {
        var cache = new h3d.prim.ModelCache();
        value = cache.loadModel(hxd.Res.Tank);

        turret = value.getMeshByName("Turret");
        turret.rotate(0,0,Std.random(91));

        scene.addChild(value);
        cache.dispose();
    }
}