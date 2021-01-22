using Extensions;

class Main extends hxd.App 
{
    var mapIndex : Int;
    var maps : Array<hxd.res.Resource>;

    var tileSize : Float;
    var ground : h3d.scene.Mesh;

    override function init() 
    {   
        ev.Courier.init();
        mng.PoolHub.init();

        mapIndex = -1;
        maps =
        [
            hxd.Res.arena_01
        ];

        tileSize = 2.0;
        placeGround(36, 26);

        buildNextLevel();

        var playerTank = new Tank(5, 1.5, 1.575, hxd.Res.tank_palette_red.toTexture());
        var player = new Player(playerTank);
        s3d.addChild(playerTank);
        
        setupCamera();
        setupLighting();

        ev.Courier.open(ev.Courier.CallbackKind.OnUpdate);

        var parts = new h3d.parts.GpuParticles(s3d);
        var g = new h3d.parts.GpuParticles.GpuPartGroup(parts);

        g.emitMode = h3d.parts.GpuParticles.GpuEmitMode.Cone;
        g.emitAngle = 0.5;
        g.emitDist = 0;

        g.fadeIn = 0;
        g.fadeOut = 0;
        g.fadePower = 0;
        g.gravity = 0;
        g.size = 7.5;
        g.sizeRand = 0.5;

        g.rotSpeed = 1;

        g.speed = 2;
        g.speedRand = 0.5;

        g.life = 5;
        g.lifeRand = 0.5;
        g.nparts = 100;
     
        g.animationRepeat = 10;
        g.frameCount = 4;
        g.frameDivisionX = 2;
        g.frameDivisionY = 2;

        g.sortMode = h3d.parts.GpuParticles.GpuSortMode.Dynamic;
        g.texture = hxd.Res.decal.toTexture();

        parts.addGroup(g);
        parts.setPosition(-2.5, 0, 2.5);
        parts.rotate(90.toRadians(), 0, 0);
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

                var poolable = mng.PoolHub.getObstaclePool(type - 1).take();
                var obstacle = poolable.getValue();

                obstacle.setPosition(start.x + x * tileSize, start.y + y * tileSize, 0);
                obstacle.init();

                s3d.addChild(poolable);
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
        //s3d.camera.orthoBounds = h3d.col.Bounds.fromValues(-extents.x * 0.5, -extents.y * 0.5, 0, extents.x, extents.y, 250);

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
        relay = new Main();
    }
}

typedef TiledMapData = { layers:Array<{ data:Array<Int> }>, width:Int, height:Int };