using Extensions;

class Extensions 
{
    static public function toObj(model : hxd.res.Model, color : Int)
    {
        var cache = new h3d.prim.ModelCache();
        var obj = cache.loadModel(model);

        for (mesh in obj.getMeshes()) mesh.material.color.setColor(color);

        return obj;
    }

    static public function getLocalBounds(obj : h3d.scene.Object)
    {
        var bounds = obj.getBounds(new h3d.col.Bounds());
        bounds.offset(-obj.x, -obj.y, 0);

        return bounds;
    }
    static public function overlaps(col : h3d.col.Collider, bounds : h3d.col.Bounds)
    {
        var min = bounds.getMin();
        min.z += bounds.zSize * 0.5;

        var max = bounds.getMax();
        max.z -= bounds.zSize * 0.5;

        var medOne = new h3d.col.Point(min.x + bounds.xSize, min.y, min.z);
        var medTwo = new h3d.col.Point(min.x, min.y + bounds.ySize, min.z);

        var rays: Array<h3d.col.Ray> = 
        [
            min.createRayTo(medOne),
            medOne.createRayTo(max),
            max.createRayTo(medTwo),
            medTwo.createRayTo(min)
        ];
        
        for (ray in rays)
        {
            var distance = col.rayIntersection(ray, true);
            if (distance > 0 && distance < ray.getDir().length()) return true;
        }
        return false;
    }
    static public function createRayTo(p1 : h3d.col.Point, p2 : h3d.col.Point)
    {
        var ray = h3d.col.Ray.fromPoints(p1, p2);
        ray.lx = p2.x - p1.x;
        ray.ly = p2.y - p1.y;
        ray.lz = p2.z - p1.z;

        return ray;
    }

    static public function refreshColor(box : h3d.scene.Box, color : Int)
    {
        box.clear();
        box.lineStyle(box.thickness, color);
        box.moveTo(box.bounds.xMin, box.bounds.yMin, box.bounds.zMin);
        box.lineTo(box.bounds.xMax, box.bounds.yMin, box.bounds.zMin);
        box.lineTo(box.bounds.xMax, box.bounds.yMax, box.bounds.zMin);
        box.lineTo(box.bounds.xMin, box.bounds.yMax, box.bounds.zMin);
        box.lineTo(box.bounds.xMin, box.bounds.yMin, box.bounds.zMin);
        box.lineTo(box.bounds.xMin, box.bounds.yMin, box.bounds.zMax);
        box.lineTo(box.bounds.xMax, box.bounds.yMin, box.bounds.zMax);
        box.lineTo(box.bounds.xMax, box.bounds.yMax, box.bounds.zMax);
        box.lineTo(box.bounds.xMin, box.bounds.yMax, box.bounds.zMax);
        box.lineTo(box.bounds.xMin, box.bounds.yMin, box.bounds.zMax);

        box.moveTo(box.bounds.xMax, box.bounds.yMin, box.bounds.zMin);
        box.lineTo(box.bounds.xMax, box.bounds.yMin, box.bounds.zMax);
        box.moveTo(box.bounds.xMin, box.bounds.yMax, box.bounds.zMin);
        box.lineTo(box.bounds.xMin, box.bounds.yMax, box.bounds.zMax);
        box.moveTo(box.bounds.xMax, box.bounds.yMax, box.bounds.zMin);
        box.lineTo(box.bounds.xMax, box.bounds.yMax, box.bounds.zMax);
    }
}