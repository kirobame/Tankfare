import hxd.poly2tri.Point;
using Extensions;

class Main extends hxd.App 
{
    var callbacks : List<CallbackKind -> Int>;

    var box : h3d.scene.Box;
    var otherBox : h3d.scene.Box;

    override function init() 
    {
        callbacks = new List<CallbackKind -> Int>();

        buildLevel(100, 100, 2.0);
        
        s3d.camera.pos = new h3d.Vector(0, 50, 75);
        s3d.camera.target = new h3d.Vector(0, 0, 0);

        var size = 4.0;
        var extents = new h3d.Vector(16 * size, 9 * size);
        s3d.camera.orthoBounds = h3d.col.Bounds.fromValues(-extents.x * 0.5, -extents.y * 0.5, 0, extents.x, extents.y, 250);

        new h3d.scene.CameraController(s3d).loadFromCamera();
    }
    override function update(dt : Float)
    {
        call(CallbackKind.OnUpdate(dt), dfltCodes);
    }

    private function buildLevel(width : Int, length : Int, size : Float)
    {
        var plane = new h3d.prim.Grid(width, length, size, size);
        plane.addNormals();
        plane.addUVs();
        
        plane.uvScale(width * 0.5, length * 0.5);
        plane.translate(-width * size * 0.5, -length * size * 0.5, 0.0);

        var tex = hxd.Res.checker.toTexture();
        tex.wrap = h3d.mat.Data.Wrap.Repeat;
        var mat = h3d.mat.Material.create(tex);

        var ground = new h3d.scene.Mesh(plane, mat, s3d);
        ground.setPosition(0, 0, 0);

        var player = new Player(0, 0);
        s3d.addChild(player);

        var offset = placeBlocks(size);
        ground.setPosition(ground.x + offset.x, ground.y + offset.y, 0);

        setupLighting();
    }
    private function placeBlocks(size : Float)
    {
        var source: Array<h3d.scene.Object> = 
        [
            hxd.Res.wall.toObj(0xFFC266)
        ];

        var halfSize = size * 0.5;

        var data:TiledMapData = haxe.Json.parse(hxd.Res.arena_01.entry.getText());
        var start = new h3d.Vector(-(data.width * size) * 0.5, -(data.height * size) * 0.5);
        start.x += halfSize;
        start.y += halfSize;

        for (i in 0...data.layers.length)
        {
            for(j in 0...data.layers[i].data.length)
            {
                var type = data.layers[i].data[j];
                if (type == 0) continue;

                var x = Std.int(j % data.width);
                var y = Std.int(j / data.width);

                var instance = source[type - 1].clone();
                instance.setPosition(start.x + x * size, start.y + y * size, 0);

                var box = new h3d.scene.Box(0x00FF00, h3d.col.Bounds.fromValues(-halfSize, -halfSize, 0, size, size, size));
                box.thickness = 4.0;
                instance.addChild(box);

                s3d.addChild(instance);
            }
        }

        return new h3d.Vector((data.width % 2) * halfSize, (data.height % 2) * halfSize);
    }
    private function setupLighting()
    {
        var light = new h3d.scene.fwd.DirLight(new h3d.Vector(0.5, 0.5, -0.5), s3d);
        light.enableSpecular = true;

        s3d.lightSystem.ambientLight.set(0.3, 0.3, 0.3);
    }

    public function subscribeTo(delegate : CallbackKind -> Int)
    {
        callbacks.add(delegate);
    }
    public function unsubscribeFrom(delegate : CallbackKind -> Int)
    {
        callbacks.remove(delegate);
    }
    public function call(kind : CallbackKind, breakCodes : Array<Int>)
    {
        for (delegate in callbacks) 
        {
            var breakCode = delegate(kind);
            if (breakCodes.contains(breakCode)) return true;
        }

        return false;
    }

    public static var relay : Main;
    public static var dfltCodes(default, null) : Array<Int>;

    static function main() 
    {
        hxd.Res.initEmbed();

        dfltCodes = [-1];
        relay = new Main();
    }
}

enum CallbackKind 
{
    OnUpdate(dt : Float);
    OnPlayerMoveIntent(bounds : h3d.col.Bounds);
}

typedef TiledMapData = { layers:Array<{ data:Array<Int> }>, width:Int, height:Int };