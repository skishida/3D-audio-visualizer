arcObj arc_time = new arcObj() {
  @Override
  void process(int i, int end) {
      dist = 100 +  volume*300*in.mix.get((int)( i/(float)end * in.bufferSize()));
      leng = 5;
  }
};

arcObj arc_time2 = new arcObj() {
  @Override
  void process(int i, int end) {
      dist = 125 +  volume*100*in.left.get((int)( i/(float)end * in.bufferSize()));
      leng = 2;
  }
};
arcObj arc_time3 = new arcObj() {
  @Override
  void process(int i, int end) {
      dist = 115 -  volume*100*in.right.get((int)( i/(float)end * in.bufferSize()));
      leng = 2;
  }
};


arcObj arc_freqL = new arcObj() {
  @Override
  void process(int i, int end) {
    if( i%10 == 0) {
      float im = (FFT_CACHE_L_IM.get(AUXcache))[(int)i/10];
      float re = (FFT_CACHE_L_RE.get(AUXcache))[(int)i/10];//
      float spec = sqrt( im*im + re*re );
      leng = 0.5 + volume*spec;
    }else{
      leng = 0.5;
    }
  }
};

arcObj arc_freqR = new arcObj() {
  @Override
  void process(int i, int end) {
    if( i%10 == 0) {
      float im = (FFT_CACHE_R_IM.get(AUXcache))[(int)i/10];
      float re = (FFT_CACHE_R_RE.get(AUXcache))[(int)i/10];//
      float spec = sqrt( im*im + re*re );
      leng = 0.5 + volume*spec;
    }else{
      leng = 0.5;
    }
  }
};

arcObj arc_outer = new arcObj() {
  @Override
  void process(int i, int end) {
    dist = 120;
    leng = 5;
    if(i>85 && i < 95) {
      leng = 0;
    }
    
    if(i>265 && i < 275) {
      leng = 0;
    }
  }
};

arcObj arc_inner = new arcObj() {
  @Override
  void process(int i, int end) {
    dist = 10;
    leng = 1.5;
  }
};

arcObj arc_middle = new arcObj() {
  @Override
  void process(int i, int end) {
    dist = 75;
    if( i%5 == 0) {
      leng = 4;
    }else{
      leng = 0.4;
    }
  }
};

arcObj arc_midairK = new arcObj() {
  @Override
  void process(int i, int end) {
    dist = 150;
    leng = 0.2;
  }
};
arcObj arc_midairL = new arcObj() {
  @Override
  void process(int i, int end) {
    dist = 152;
    leng = 0.2;
  }
};
arcObj arc_midairM = new arcObj() {
  @Override
  void process(int i, int end) {
    dist = 154;
    leng = 0.2;
  }
};

void setupArcObjs() {
  
  int num = 120;
  arc_time.setPosition(0, 0, 10)
    .setColor(cLimeGreen)
    .setWidth( 360/num/8.)
    .setBetween(0, 120)
    .setisScaled(true);
    
  arc_time2.setPosition(0, 0, 24)
    .setColor(cLimeGreen)
    .setWidth( 360/num/8.)
    .setBetween(0, 120)
    .setisScaled(true);
    
  arc_time3.setPosition(0, 0, 24)
    .setColor(cLimeGreen)
    .setWidth( 360/num/8.)
    .setBetween(0, 120)
    .setisScaled(true);
    
  arc_freqL.setPosition(0, 0, 20)
    .setColor(cLiteBlue)
    .setWidth(0.5)
    .setBetween(0, 360)
    .setisScaled(false);
    
  arc_freqR.setPosition(0, 0, 20)
    .setColor(cLiteBlue)
    .setWidth(0.5)
    .setBetween(0, 360)
    .setRotate(0,0,PI + radians(5))
    .setisScaled(false);
    
  arc_outer.setPosition(0, 0, 25)
    .setColor(cLiteBlue)
    .setWidth(0.5)
    .setBetween(0, 360)
    .setisScaled(false).
    setRotationSpeed(0,0,0.0005);
    
  arc_inner.setPosition(0, 0, 30)
    .setColor(cLimeGreen)
    .setWidth(0.5)
    .setBetween(0, 360)
    .setisScaled(false);
    
  arc_midairK.setPosition(0, 0, 30)
    .setColor(cMagenta)
    .setWidth( 360/num/16.)
    .setBetween(0, 360)
    .setisScaled(true)
    .setRotationSpeed(0.0029, 0.0011 ,0.0017);
  arc_midairL.setPosition(0, 0, 30)
    .setColor(cLiteBlue)
    .setWidth( 360/num/16.)
    .setBetween(0, 360)
    .setisScaled(true)
    .setRotationSpeed(0.0023, -0.0013 ,0.0031);
  arc_midairM.setPosition(0, 0, 30)
    .setColor(cLimeGreen)
    .setWidth( 360/num/16.)
    .setBetween(0, 360)
    .setisScaled(true)
    .setRotationSpeed(-0.0031, 0.0019 ,0.0007);
    
  arc_middle.setPosition(0, 0, 10)
    .setColor(cLimeGreen)
    .setWidth(0.5)
    .setWidth( 360/num/8.)
    .setBetween(0, 180)
    .setisScaled(true);
    
  sceneObj.add(arc_time);
  sceneObj.add(arc_time2);
  sceneObj.add(arc_time3);
  sceneObj.add(arc_freqL);
  sceneObj.add(arc_freqR);
  sceneObj.add(arc_outer);
  sceneObj.add(arc_inner);
  sceneObj.add(arc_midairK);
  sceneObj.add(arc_midairL);
  sceneObj.add(arc_midairM);
  sceneObj.add(arc_middle);
}

class triadOrnament {
  protected float _dist;
  protected float _speed;
  protected color _col;
  arcObj arc_ornament = new arcObj() {
    @Override
    void process(int i, int end) {
      if( i%60==0) {
        leng = 2;
        dist = _dist - 2 + 0.5;
      }else{
        dist = _dist;
        leng = 0.5;
      }
    }
  };
  
  arcObj arc_ornament2 = new arcObj() {
    @Override
    void process(int i, int end) {
      if( i%60==0) {
        leng = 2;
        dist = _dist - 2 + 0.5;
      }else{
        dist = _dist;
        leng = 0.5;
      }
    }
  };
  
  arcObj arc_ornament3 = new arcObj() {
    @Override
    void process(int i, int end) {
      if( i%60==0) {
        leng = 2;
        dist = _dist - 2 + 0.5;
      }else{
        dist = _dist;
        leng = 0.5;
      }
    }
  };

  triadOrnament(ArrayList<arcObj> li, float d, float r, color c) {
    this._dist = d;
    this._speed = r;
    this._col = c;
    arc_ornament.setPosition(0, 0, 15)
      .setColor(_col)
      .setWidth(0.5)
      .setBetween(0, 61)
      .setisScaled(false)
      .setRotationSpeed(0, 0, _speed);
      
    arc_ornament2.setPosition(0, 0, 15)
      .setColor(_col)
      .setWidth(0.5)
      .setBetween(0, 61)
      .setisScaled(false)
      .setRotationSpeed(0, 0, _speed)
      .setRotate(0, 0, radians(120));
      
    arc_ornament3.setPosition(0, 0, 15)
      .setColor(_col)
      .setWidth(0.5)
      .setBetween(0, 61)
      .setisScaled(false)
      .setRotationSpeed(0, 0, _speed)
      .setRotate(0, 0, radians(240));
      
    li.add(arc_ornament);
    li.add(arc_ornament2);
    li.add(arc_ornament3);
  }
}

class quartetOrnament {
  protected float _dist;
  protected float _speed;
  protected color _col;
  arcObj arc_ornament = new arcObj() {
    @Override
    void process(int i, int end) {
      if( i%70==0) {
        leng = 2;
        dist = _dist - 2 + 0.5;
      }else{
        dist = _dist;
        leng = 0.5;
      }
    }
  };
  
  arcObj arc_ornament2 = new arcObj() {
    @Override
    void process(int i, int end) {
      if( i%70==0) {
        leng = 2;
        dist = _dist - 2 + 0.5;
      }else{
        dist = _dist;
        leng = 0.5;
      }
    }
  };
  
  arcObj arc_ornament3 = new arcObj() {
    @Override
    void process(int i, int end) {
      if( i%70==0) {
        leng = 2;
        dist = _dist - 2 + 0.5;
      }else{
        dist = _dist;
        leng = 0.5;
      }
    }
  };
  
  arcObj arc_ornament4 = new arcObj() {
    @Override
    void process(int i, int end) {
      if( i%70==0) {
        leng = 2;
        dist = _dist - 2 + 0.5;
      }else{
        dist = _dist;
        leng = 0.5;
      }
    }
  };

  quartetOrnament(ArrayList<arcObj> li, float d, float r, color c) {
    this._dist = d;
    this._speed = r;
    this._col = c;
    arc_ornament.setPosition(0, 0, 15)
      .setColor(_col)
      .setWidth(0.5)
      .setBetween(0, 71)
      .setisScaled(false)
      .setRotationSpeed(0, 0, _speed);
      
    arc_ornament2.setPosition(0, 0, 15)
      .setColor(_col)
      .setWidth(0.5)
      .setBetween(0, 71)
      .setisScaled(false)
      .setRotationSpeed(0, 0, _speed)
      .setRotate(0, 0, radians(90));
      
    arc_ornament3.setPosition(0, 0, 15)
      .setColor(_col)
      .setWidth(0.5)
      .setBetween(0, 71)
      .setisScaled(false)
      .setRotationSpeed(0, 0, _speed)
      .setRotate(0, 0, radians(180));
      
    arc_ornament4.setPosition(0, 0, 15)
      .setColor(_col)
      .setWidth(0.5)
      .setBetween(0, 71)
      .setisScaled(false)
      .setRotationSpeed(0, 0, _speed)
      .setRotate(0, 0, radians(270));
      
    li.add(arc_ornament);
    li.add(arc_ornament2);
    li.add(arc_ornament3);
    li.add(arc_ornament4);
  }
}