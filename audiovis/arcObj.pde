// 円弧上に長方形を並べるクラス
class arcObj { // TODO:implements Cloneable
  protected float s; // サイズ
  protected PVector pos = new PVector(0,0,0); // ポジション
  protected PVector posrotate = new PVector(0,0,0); // 回転角度
  protected PVector rotate = new PVector(0,0,0); // 回転速度
  protected color reccolor = color(128); // 色
  protected float dist = 50; // 半径
  protected float leng = 0.01; // 半径方向の長さ
  protected float wid = 0.5; // 円弧方向の幅
  protected int start = 0; // 開始率(弧度法 or 分割数)
  protected int end = 359; // 終点率(弧度法 or 分割数)
  protected boolean maxScale = false; // 弧度法 or 分割
  
  void draw(){
    pushMatrix();
      this.posrotate = PVector.add(this.posrotate, this.rotate);
      translate(this.pos.x, this.pos.y, this.pos.z);
      rotateX(this.posrotate.x);
      rotateY(this.posrotate.y);
      rotateZ(this.posrotate.z);
      noStroke();
      fill(reccolor);
      for(int i=0; i<end; i++) {
        float radp,radn;
        if(maxScale) {
          radp = radians(360 * i/end + this.wid);
          radn = radians(360 * i/end - this.wid);
        }else{
          radp = radians(360 * i/360. + this.wid);
          radn = radians(360 * i/360. - this.wid);
        }
        this.process(i, end);
        float sp = 1 * sin(radp);
        float cp = 1 * cos(radp);
        float sn = 1 * sin(radn);
        float cn = 1 * cos(radn);
        beginShape(QUADS);
          vertex( cn*(dist-leng), sn*(dist-leng), 0);  
          vertex( cp*(dist-leng), sp*(dist-leng), 0);  
          vertex( cp*(dist+leng), sp*(dist+leng), 0);  
          vertex( cn*(dist+leng), sn*(dist+leng), 0);  
        endShape();
      }
    popMatrix();
  };
  // 長方形のサイズを変える
  public void process(int i, int end){};
  
  // 色を変える
  public arcObj setColor(color c) {
    this.reccolor = c;
    return this;
  }
  
  // true 後述の開始・終端で360度の円を作る つまり0~120と指定するとスカスカに描かれる
  // false 開始・終端を角度として円弧を描く
  public arcObj setisScaled(boolean s) {
    this.maxScale = s;
    return this;
  }
  
  // 円弧の開始・終端を指定する
  public arcObj setBetween(int s, int e) {
    this.start = s;
    this.end = e;
    return this;
  }
  
  // スケール設定
  public arcObj setScale(float s) {
    this.s = s;
    return this;
  }
  
  // 一個あたりの幅を変える setBetween(0,360)のとき0.5で連続に見える
  public arcObj setWidth(float w) {
    this.wid = w;
    return this;
  }
  
  // 円弧の中心座標を指定
  public arcObj setPosition(float x, float y, float z){
    this.pos = new PVector(x, y, z);
    return this;
  }
  
  // 回転
  public arcObj setRotate(float x, float y, float z) {
    this.posrotate = new PVector(x, y, z);
    return this;
  }
  // 回転速度の指定 単位 rad per frame
  public arcObj setRotationSpeed(float x, float y, float z) {
    this.rotate = new PVector(x, y, z);
    return this;
  }
  public PVector getPosition() {
    return this.pos;
  }
  
  // TODO
  //@Override
  //public arcObj clone() {
  //  try {
  //     arcObj coneArc = (arcObj) super.clone();
  //     return coneArc;
  //  } catch (CloneNotSupportedException e) {
  //  }
  //  return this;
  //}
}