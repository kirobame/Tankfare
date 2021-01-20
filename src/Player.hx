import Main.CallbackKind;

class Player extends h3d.scene.Object
{ 
    var graph : h3d.scene.Object;
    var turret : h3d.scene.Mesh;

    var movSpeed : Float;
    var turnSpeed : Float;

    var lPlane : h3d.col.Plane;
    var lPoint : h3d.col.Point;

    public function new(x : Int, y : Int)
    {
        super();
        setPosition(x, y, 0);
        
        setupVariables();
        setupGraph();
        setupDelegates();
    }
    private function setupGraph()
    {
        var cache = new h3d.prim.ModelCache();
        graph = cache.loadModel(hxd.Res.tank);

        graph.rotate(0, 0, 90 * (Math.PI / 180));
        turret = graph.getMeshByName("Turret");

        addChild(graph);
        cache.dispose();
    }
    private function setupVariables()
    {
        movSpeed = 5;
        turnSpeed = 1.5;

        var n = new h3d.col.Point(0, 0, 1);
        var p = new h3d.col.Point(0, 0, 0);
        lPlane = h3d.col.Plane.fromNormalPoint(n, p);

        lPoint = new h3d.col.Point(x + 10, y, 0);
    }
    private function setupDelegates()
    {
        Main.relay.subscribeTo(onCallback);
        hxd.Window.getInstance().addEventTarget(onEvent);
    }

    private function move(movIntent : Float, dt : Float)
    {
        var direction = qRot.getDirection();
        
        movIntent *= dt;
        direction.x *= movIntent;
        direction.y *= -movIntent;

        setPosition(x + direction.x, y + direction.y, 0);
    }
    private function turn(turnIntent : Float, dt : Float)
    {
        rotate(0, 0, turnIntent * dt);
    }
    private function updateLookRotation()
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

    function onCallback(kind : CallbackKind)
    {
        switch(kind)
        {
            case OnUpdate(dt): onUpdate(dt);
            case _:
        }

        return 0;
    }
    function onUpdate(dt : Float)
    {
        updateLookRotation();

        var turnIntent = 0.0;
        if (hxd.Key.isDown(68)) turnIntent += turnSpeed;
        if (hxd.Key.isDown(81)) turnIntent -= turnSpeed;

        if (turnIntent != 0) turn(turnIntent, dt);

        var movIntent = 0.0;
        if (hxd.Key.isDown(90)) movIntent += movSpeed;
        if (hxd.Key.isDown(83)) movIntent -= movSpeed;

        if (movIntent != 0) move(movIntent, dt);
    }

    private function setLookingPoint(x : Float, y : Float)
    {
        var ray = Main.relay.s3d.camera.rayFromScreen(x, y);
        lPoint = ray.intersect(lPlane);
    }

    function onEvent(event : hxd.Event)
    {
        switch(event.kind)
        {
            case EMove: setLookingPoint(event.relX, event.relY);
            case _:
        }
    }
}