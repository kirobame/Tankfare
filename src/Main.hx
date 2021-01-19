import h3d.scene.Mesh;

class Main extends hxd.App 
{
    override function init() 
    {
        var light = new h3d.scene.fwd.DirLight(new h3d.Vector(0.5,0.5,-0.5), s3d);
        light.enableSpecular = true;

        s3d.lightSystem.ambientLight.set(0.3,0.3,0.3);

        var cache = new h3d.prim.ModelCache();
        var obj = cache.loadModel(hxd.Res.Tank);

        var turretMesh = obj.getMeshByName("Turret");
        turretMesh.rotate(0,0,Std.random(91));

        s3d.addChild(obj);

        new h3d.scene.CameraController(s3d).loadFromCamera();
        cache.dispose();
    }

    static function main() 
    {
        hxd.Res.initEmbed();
        new Main();
    }
}