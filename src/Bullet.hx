import h3d.parts.Particles;
import h3d.parts.GpuParticles;
using Extensions;

class Bullet extends Observable
{
    var graphs : h3d.scene.Object;

    var dir : h3d.Vector;
    var speed : Float;

    var bMaxCount : Int;
    var bounces : Int;

    var vfx : h3d.parts.GpuParticles;
    var rTimer : Float;

    public function new(graphs : h3d.scene.Object, speed : Float, bMaxCount : Int)
    {
        super();

        this.bMaxCount = bMaxCount;
        this.speed = speed;
        this.graphs = graphs;

        addChild(graphs);
        graphs.setPosition(0, 0, 0);

        vfx = new h3d.parts.GpuParticles(this);
        vfx.material.mainPass.setBlendMode(h3d.mat.BlendMode.Alpha);

        var duration = 1.0;
        var count = 10;
        for(i in 0...count)
        {
            var group = new h3d.parts.GpuParticles.GpuPartGroup(vfx);

            group.emitMode = h3d.parts.GpuEmitMode.Cone;
            group.emitAngle = 0;
            group.emitDist = 0;
            group.emitSync = 1.0;
            group.emitDelay = (duration / count) * i;

            group.size = 0.05;
            group.fadeIn = 0;
            group.fadeOut = 0;

            group.life = 1;
            group.nparts = 1;

            group.frameCount = 12;
            group.frameDivisionX = 6;
            group.frameDivisionY = 2;

            group.texture = hxd.Res.smoke_trail_sheet.toTexture();
            vfx.addGroup(group);
        }

        ev.Courier.open(ev.Courier.CallbackKind.OnBulletTransformIntent);
    }

    public function launch(dir : h3d.Vector)
    {
        bounces = bMaxCount;

        dir.normalize();
        this.dir = dir;

        actualizeRotation();
        rTimer = 0;

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

                if (rTimer > 0)
                {
                    if (rTimer > 2)
                    {
                        sendCallback(Observable.ObjectCallbackKind.OnBinned);
                        ev.Courier.unsubscribeFrom(ev.Courier.CallbackKind.OnUpdate, onUpdate);
                    }
                        
                    rTimer += dt;
                    return ev.Courier.ListenerOutput.Empty;
                }

                var displacement = new h3d.col.Point(dir.x * speed * dt, dir.y * speed * dt);
                var ray = h3d.col.Ray.fromValues(x,y,z, dir.x, dir.y, 0);

                var args = ev.Courier.CallbackArgs.RayArgs(ray, displacement.length());
                var output = ev.Courier.ping(ev.Courier.CallbackKind.OnBulletTransformIntent, args);

                if (output != ev.Courier.ListenerOutput.Empty)
                {
                    if (bounces == 0)
                    {
                        graphs.visible = false;
                        rTimer += dt;

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
        o.name = "Bullet";

        return o;
    }
}