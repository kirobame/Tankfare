import h3d.scene.Mesh;
import h3d.prim.Cube;

class Main extends hxd.App 
{
    var builder : Builder;
    var callbacks : Map<CallbackGroup, List<CallbackKind -> Void>>;

    override function init() 
    {
        builder = new Builder();
        callbacks = new Map<CallbackGroup, List<CallbackKind -> Void>>();

        buildLevel(100, 100);
        s3d.camera.pos = new h3d.Vector(0, 50, 75);
        s3d.camera.target = new h3d.Vector(0, 0, 0);
    }
    override function update(dt : Float)
    {
        call(CallbackGroup.Core, CallbackKind.OnUpdate(dt));
    }

    private function buildLevel(width : Int, length : Int)
    {
        var plane = new h3d.prim.Grid(width, length, 10, 10);
        plane.addNormals();
        plane.addUVs();
        
        plane.uvScale(width, length);
        plane.translate(-width * 5, -length * 5, 0.0);

        var tex = hxd.Res.checker.toTexture();
        tex.wrap = h3d.mat.Data.Wrap.Repeat;
        var mat = h3d.mat.Material.create(tex);

        var ground = new h3d.scene.Mesh(plane, mat, s3d);
        var player = new Player(0, 0);

        s3d.addChild(player);

        placeBlocks();
        setupLighting();
    }
    private function placeBlocks()
    {
        builder.parse(hxd.Res.arena_01.entry.getText());
    }
    private function setupLighting()
    {
        var light = new h3d.scene.fwd.DirLight(new h3d.Vector(0.5, 0.5, -0.5), s3d);
        light.enableSpecular = true;

        s3d.lightSystem.ambientLight.set(0.3, 0.3, 0.3);
    }

    public function subscribeTo(group : CallbackGroup, delegate : CallbackKind -> Void)
    {
        if (!callbacks.exists(group))
        {
            var list = new List<CallbackKind -> Void>();
            list.add(delegate);

            callbacks.set(group, list);
            return;
        }

        callbacks.get(group).add(delegate);
    }
    public function unsubscribeFrom(group : CallbackGroup, delegate : CallbackKind -> Void)
    {
        if (!callbacks.exists(group)) return;
        callbacks.get(group).remove(delegate);
    }

    public function call(group : CallbackGroup, kind : CallbackKind)
    {
        if (!callbacks.exists(group)) return;
        for (delegate in callbacks.get(group)) delegate(kind);
    }

    public static var relay : Main;

    static function main() 
    {
        hxd.Res.initEmbed();
        relay = new Main();
    }
}

enum CallbackGroup
{
    Core;
    Player;
}
enum CallbackKind 
{
    OnUpdate(dt : Float);
}