class Tank extends h3d.scene.Object
{
    public var lookHeight(default, null) : Float;

    var graph : h3d.scene.Object;
    var turret : h3d.scene.Mesh;

    var movSpeed : Float;
    var turnSpeed : Float;
    var lPoint : h3d.col.Point;

    var box : h3d.scene.Mesh;

    public function new(movSpeed : Float, turnSpeed : Float, lookHeight : Float, texture : h3d.mat.Texture)
    {
        super();

        this.movSpeed = movSpeed;
        this.turnSpeed = turnSpeed;

        this.lookHeight = lookHeight;
        lPoint = new h3d.col.Point(x + 10, y, lookHeight);

        setupGraphs(texture);
        setupCollision();
    }
    private function setupGraphs(texture : h3d.mat.Texture)
    {
        var cache = new h3d.prim.ModelCache();
        graph = cache.loadModel(hxd.Res.tank);

        for (mesh in graph.getMeshes()) mesh.material.texture = texture;

        graph.rotate(0, 0, 90 * (Math.PI / 180));
        turret = graph.getMeshByName("Turret");

        addChild(graph);
        cache.dispose();
    }
    private function setupCollision()
    {
        var bounds = graph.getMeshByName("Base").getBounds(new h3d.col.Bounds());
        var prim = new h3d.prim.Cube(bounds.xSize, bounds.ySize, bounds.zSize, false);
        prim.translate(-bounds.xSize * 0.5, -bounds.ySize * 0.5, 0);
        prim.addNormals();
        prim.addUVs();

        box = new h3d.scene.Mesh(prim);
        box.material.blendMode = h3d.mat.BlendMode.Alpha;
        box.material.color.set(0, 1, 0, 0.25);
        box.visible = false;

        addChild(box);
    }
    
    public function setLookingPoint(x : Float, y : Float)
    {
        lPoint.x = x;
        lPoint.y = y;
        lPoint.z = lookHeight;
    }

    public function move(movIntent : Float, dt : Float)
    {
        var direction = qRot.getDirection();
            
        movIntent *= dt * movSpeed;
        direction.x *= movIntent;
        direction.y *= -movIntent;

        setPosition(x + direction.x, y + direction.y, 0);
        if (!canApplyTransformation())
        {
            setPosition(x - direction.x, y - direction.y, 0);
            return false;
        }
        
        return true;
    }
    public function turn(turnIntent : Float, dt : Float)
    {
        rotate(0, 0, turnIntent * turnSpeed * dt);
        if (!canApplyTransformation())
        {
            rotate(0, 0, -turnIntent * turnSpeed * dt);    
            return false;
        }  

        return true;
    }
    public function look()
    {
        var direction = new h3d.Vector(lPoint.x - x, lPoint.y - y);
        direction.normalize();

        var rotation = qRot.clone();
        rotation.conjugate();

        var quat = new h3d.Quat();
        quat.initDirection(direction);
        quat.multiply(quat, rotation);

        turret.setRotationQuat(quat);
    }

    private function canApplyTransformation()
    {
        var collider = box.getCollider();
        var args = ev.Courier.CallbackArgs.ColliderArgs(collider);

        if (ev.Courier.ping(ev.Courier.CallbackKind.OnTankTransformIntent, args) != ev.Courier.ListenerOutput.Empty) 
        {
            box.material.color.set(1, 0, 0, 0.25);
            return false;
        }
    
        box.material.color.set(0, 1, 0, 0.25);
        return true;
    }
}