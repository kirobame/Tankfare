using Extensions;

class Decal extends Observable
{
    var size : Float;
    var tex : h3d.mat.Texture;

    public function new(size : Float, tex : h3d.mat.Texture)
    {
        super();

        this.size = size;
        this.tex = tex;

        var points : Array<h3d.col.Point> = 
        [
            new h3d.col.Point(-0.5, 0.5),
            new h3d.col.Point(0.5, 0.5),
            new h3d.col.Point(-0.5, -0.5),
            new h3d.col.Point(0.5, -0.5)
        ];
        var uvs : Array<h3d.prim.UV> = 
        [
            new h3d.prim.UV(0, 1),
            new h3d.prim.UV(1, 1),
            new h3d.prim.UV(0, 0),
            new h3d.prim.UV(1, 0)
        ];
        var normals : Array<h3d.col.Point> = 
        [
            new h3d.col.Point(0 , 0, -1),
            new h3d.col.Point(0 , 0, -1),
            new h3d.col.Point(0 , 0, -1),
            new h3d.col.Point(0 , 0, -1)
        ];
        var quad = new h3d.prim.Quads(points, uvs, normals);  

        var matrix = new h3d.Matrix();
        matrix.initRotation(180.toRadians(), 0, 0);
        matrix.scale(size, size);

        quad.transform(matrix);

        var mat = h3d.mat.Material.create(tex);
        mat.castShadows = false;
        mat.blendMode = h3d.mat.BlendMode.Alpha;
        mat.textureShader.killAlpha = true;

        addChild(new h3d.scene.Mesh(quad, mat));
    }

    override function clone(?o:h3d.scene.Object):h3d.scene.Object 
    {
        if (o == null) o = new Decal(size, tex);
        super.clone(o);

        return o;
    }
}