import h3d.scene.Mesh;
using Extensions;

class Player extends h3d.scene.Object
{ 
    var tank : Tank;
    var lPlane : h3d.col.Plane;

    public function new(tank : Tank)
    {
        super();
        this.tank = tank;

        var n = new h3d.col.Point(0, 0, 1);
        var p = new h3d.col.Point(0, 0, tank.lookHeight);
        lPlane = h3d.col.Plane.fromNormalPoint(n, p);

        tank.addChild(this);

        ev.Courier.subscribeTo(ev.Courier.CallbackKind.OnUpdate, onUpdate);
        hxd.Window.getInstance().addEventTarget(onEvent);
    }

    function onUpdate(args : ev.Courier.CallbackArgs)
    {
        switch(args)
        {
            case ev.Courier.CallbackArgs.FloatArgs(dt):

                var hasTransformChanged = false;

                var turnIntent = 0.0;
                if (hxd.Key.isDown(68)) turnIntent += 1.0;
                if (hxd.Key.isDown(81)) turnIntent -= 1.0;
        
                if (turnIntent != 0)
                {
                    var result = tank.turn(turnIntent, dt);
                    if (!hasTransformChanged && result) hasTransformChanged = true;
                } 
        
                var movIntent = 0.0;
                if (hxd.Key.isDown(90)) movIntent += 1.0;
                if (hxd.Key.isDown(83)) movIntent -= 1.0;
        
                if (movIntent != 0) 
                {
                    var result = tank.move(movIntent, dt);
                    if (!hasTransformChanged && result) hasTransformChanged = true;
                }

                if (hasTransformChanged) tank.look();

            case _:
        }

        return ev.Courier.ListenerOutput.Empty;
    }

    function onEvent(event : hxd.Event)
    {
        switch(event.kind)
        {
            case EMove: 
                var ray = Main.relay.s3d.camera.rayFromScreen(event.relX, event.relY);
                var lPoint = ray.intersect(lPlane);

                tank.setLookingPoint(lPoint.x, lPoint.y);
                tank.look();
            
            case ERelease: tank.fire(0);

            case _:
        }
    }
}