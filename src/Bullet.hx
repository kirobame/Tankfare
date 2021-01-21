class Bullet extends Observable
{
    var graphs : h3d.scene.Object;

    var dir : h3d.Vector;
    var speed : Float;

    var bMaxCount : Int;
    var bounces : Int;

    public function new(graphs : h3d.scene.Object, speed : Float, bMaxCount : Int)
    {
        super();

        this.bMaxCount = bMaxCount;
        this.speed = speed;
        this.graphs = graphs;

        addChild(graphs);
        graphs.setPosition(0, 0, 0);

        ev.Courier.open(ev.Courier.CallbackKind.OnBulletTransformIntent);
    }

    public function launch(dir : h3d.Vector)
    {
        bounces = bMaxCount;

        dir.normalize();
        this.dir = dir;

        actualizeRotation();

        ev.Courier.subscribeTo(ev.Courier.CallbackKind.OnUpdate, onUpdate);
    }
    private function actualizeRotation()
    {
        qRot.initDirection(dir);
        rotate(0, 0, 90 * (Math.PI / 180));
    }

    function onUpdate(args : ev.Courier.CallbackArgs)
    {
        switch(args)
        {
            case ev.Courier.CallbackArgs.FloatArgs(dt) :

                var displacement = new h3d.col.Point(dir.x * speed * dt, dir.y * speed * dt);
                var ray = h3d.col.Ray.fromValues(x,y,z, dir.x, dir.y, 0);

                var args = ev.Courier.CallbackArgs.RayArgs(ray, displacement.length());
                var output = ev.Courier.ping(ev.Courier.CallbackKind.OnBulletTransformIntent, args);

                if (output != ev.Courier.ListenerOutput.Empty)
                {
                    if (bounces == 0)
                    {
                        sendCallback(Observable.ObjectCallbackKind.OnBinned);
                        ev.Courier.unsubscribeFrom(ev.Courier.CallbackKind.OnUpdate, onUpdate);

                        return ev.Courier.ListenerOutput.Empty;
                    }
                    bounces--;

                    switch(output)
                    {
                        case ev.Courier.ListenerOutput.Reflect(point, norm):

                            dir = dir.reflect(norm);
                            setPosition(point.x, point.y, z);

                            actualizeRotation();

                            return ev.Courier.ListenerOutput.Empty;

                        case _: 
                    }
                }
                setPosition(x + displacement.x, y + displacement.y, z);

            case _:
        }

        return ev.Courier.ListenerOutput.Empty;
    }
    
    override function clone(?o:h3d.scene.Object):h3d.scene.Object 
    {
        if (o == null) o = new Bullet(graphs.clone(), speed, bMaxCount);
        super.clone(o);

        return o;
    }
}