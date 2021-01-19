import h3d.mat.Texture;
import h3d.prim.Grid;
import h3d.scene.Mesh;

class Main extends hxd.App 
{
    var player : Player;

    override function init() 
    {
        buildLevel(100, 100);
        new h3d.scene.CameraController(s3d).loadFromCamera();
    }

    private function buildLevel(width : Int, length : Int)
    {
        var plane = new Grid(width, length, 10, 10);
        plane.addNormals();
        plane.addUVs();
        plane.translate(-width * 5, -length * 5, 0.0);

        var tex = Texture.genChecker(625);
        var mat = h3d.mat.Material.create(tex);

        var ground = new Mesh(plane, mat, s3d);
        player = new Player(s3d, 0, 0);

        setupLighting();
    }
    private function setupLighting()
    {
        var light = new h3d.scene.fwd.DirLight(new h3d.Vector(0.5, 0.5, -0.5), s3d);
        light.enableSpecular = true;

        s3d.lightSystem.ambientLight.set(0.3, 0.3, 0.3);
    }

    public static var relay : Main;

    static function main() 
    {
        hxd.Res.initEmbed();
        relay = new Main();
    }
}