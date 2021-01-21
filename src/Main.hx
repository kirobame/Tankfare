using Extensions;

class Main extends hxd.App 
{
    var obstaclePools : Array<mng.Pool<Obstacle>>;

    var mapIndex : Int;
    var maps : Array<hxd.res.Resource>;

    var tileSize : Float;
    var ground : h3d.scene.Mesh;

    override function init() 
    {
        obstaclePools =
        [
            new mng.Pool<Obstacle>(new Obstacle(hxd.Res.wall.toObj(0xFFC266)), 50)
        ];
             
        mapIndex = -1;
        maps =
        [
            hxd.Res.arena_01
        ];

        tileSize = 2.0;
        placeGround(36, 26);

        buildNextLevel();

        var playerTank = new Tank(5, 1.5, 1.5, hxd.Res.tank_palette_red.toTexture());
        var player = new Player(playerTank);
        s3d.addChild(playerTank);
        
        setupCamera();
        setupLighting();
    }
    override function update(dt : Float)
    {
        ev.Courier.call(ev.Courier.CallbackKind.OnUpdate, ev.Courier.CallbackArgs.FloatArgs(dt));
    }

    private function buildNextLevel()
    {
        mapIndex++;
        var data:TiledMapData = haxe.Json.parse(maps[mapIndex].entry.getText());

        var offset = placeBlocks(data);
        ground.setPosition(offset.x, offset.y, 0);
    }

    private function placeGround(width : Int, length)
    {
        var plane = new h3d.prim.Grid(width, length, tileSize, tileSize);
        plane.addNormals();
        plane.addUVs();
        
        plane.uvScale(width * 0.5, length * 0.5);
        plane.translate(-width * tileSize * 0.5, -length * tileSize * 0.5, 0.0);

        var tex = hxd.Res.checker.toTexture();
        tex.wrap = h3d.mat.Data.Wrap.Repeat;
        var mat = h3d.mat.Material.create(tex);

        ground = new h3d.scene.Mesh(plane, mat, s3d);
        ground.setPosition(0, 0, 0);
    }
    private function placeBlocks(data : TiledMapData)
    {
        var halfSize = tileSize * 0.5;

        var start = new h3d.Vector(-(data.width * tileSize) * 0.5, -(data.height * tileSize) * 0.5);
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

                var instance = obstaclePools[type - 1].take();
                instance.getValue().setPosition(start.x + x * tileSize, start.y + y * tileSize, 0);

                s3d.addChild(instance);
            }
        }

        return new h3d.Vector((data.width % 2) * halfSize, (data.height % 2) * halfSize);
    }

    private function setupCamera()
    {
        s3d.camera.pos = new h3d.Vector(0, 50, 75);
        s3d.camera.target = new h3d.Vector(0, 0, 0);

        var size = 4.0;
        var extents = new h3d.Vector(16 * size, 9 * size);
        s3d.camera.orthoBounds = h3d.col.Bounds.fromValues(-extents.x * 0.5, -extents.y * 0.5, 0, extents.x, extents.y, 250);

        new h3d.scene.CameraController(s3d).loadFromCamera();
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
        ev.Courier.init();

        relay = new Main();
    }
}

typedef TiledMapData = { layers:Array<{ data:Array<Int> }>, width:Int, height:Int };