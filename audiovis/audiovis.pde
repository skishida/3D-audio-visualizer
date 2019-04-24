import processing.opengl.*;
import ddf.minim.analysis.*; 
import ddf.minim.*;// FFTライブラリ
import peasy.*; // カメラライブラリ
import java.util.concurrent.*;
import java.lang.System;

Minim minim;
AudioInput in; // 内蔵音源
//AudioPlayer in; // 外部音源
AudioOutput out;
BeatDetect beat;

FFT fft_r,fft_l;

// 音量(描画ゲイン設定)
float volume = 1.0;

// camera control
PeasyCam peasycam;

// レイヤ
PGraphics3D PGRender; // メインレイヤ

// 色
final color cLimeGreen = color(157, 238, 19);
final color cLiteBlue = color(3, 252, 235);
final color cMagenta = color(239, 2, 231);

// FFT 配列
final int AUX_CACHE_SIZE = 3;
int[] indexlist = new int[AUX_CACHE_SIZE*2];
int AUXcache=0;
ArrayList<float[]> FFT_CACHE_L_RE = new ArrayList<float[]>();
ArrayList<float[]> FFT_CACHE_L_IM = new ArrayList<float[]>();
ArrayList<float[]> FFT_CACHE_R_RE = new ArrayList<float[]>();
ArrayList<float[]> FFT_CACHE_R_IM = new ArrayList<float[]>();
ArrayList<float[]> FFT_CACHE_R_POW = new ArrayList<float[]>();
ArrayList<float[]> FFT_CACHE_L_POW = new ArrayList<float[]>();
ArrayList<float[]> WAV_CACHE_R = new ArrayList<float[]>();
ArrayList<float[]> WAV_CACHE_L = new ArrayList<float[]>();
float[] nullFloatArray = new float[1024];

float[] doremi12 = {261.626,277.183,293.665,311.127,329.628,349.228,369.994,391.995,415.305,440.000,466.164,493.883};
ArrayList<arcObj> sceneObj = new ArrayList<arcObj>();
triadOrnament to = new triadOrnament(sceneObj, 60, 0.002, cLiteBlue);
quartetOrnament qo = new quartetOrnament(sceneObj, 70, -0.003, cLiteBlue);

void setup() {
  // 描画そのものに関する設定
  size(1920, 1080, P3D);
  frameRate(60);
  smooth();
  PGRender = (PGraphics3D)createGraphics(width, height, P3D);
  
  // 周辺ライブラリ初期設定
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 1024); // 内蔵音源
  //in = minim.loadFile("./xmas.mp3",1024); // 外部音源
  //in.loop(); // 外部音源
  fft_r = new FFT(in.bufferSize(), in.sampleRate());
  fft_l = new FFT(in.bufferSize(), in.sampleRate());
  beat = new BeatDetect(in.bufferSize(), in.sampleRate());
  
  println("in buf:" + in.bufferSize());
  println("in sample:" +in.sampleRate());
  println("fft time:" + fft_l.timeSize()); // FFTサイズ
  println("fft spec:" + fft_l.specSize()); // FFT変換結果のサイズ(折り返し)
  
  peasycam = new PeasyCam(this, 0, 0, 0, 1000);
  peasycam.setRotations(  1.085,  -0.477,   2.910);

  // 変数初期化
  for(int i=0; i<AUX_CACHE_SIZE; i++) {
    FFT_CACHE_R_IM.add(nullFloatArray);
    FFT_CACHE_R_RE.add(nullFloatArray);
    FFT_CACHE_L_IM.add(nullFloatArray);
    FFT_CACHE_L_RE.add(nullFloatArray);
    FFT_CACHE_L_POW.add(nullFloatArray);
    FFT_CACHE_R_POW.add(nullFloatArray);
    WAV_CACHE_L.add(nullFloatArray);
    WAV_CACHE_R.add(nullFloatArray);
  }
  
  for(int i=0; i< AUX_CACHE_SIZE; i++) {
    indexlist[i] = i;
    indexlist[i+AUX_CACHE_SIZE] = i;
  }
  
  setupArcObjs();
  
  // FFTは別スレッドで処理
  ScheduledExecutorService schedule = Executors.newSingleThreadScheduledExecutor();
  schedule.scheduleAtFixedRate(new process(), 0, 10, TimeUnit.MILLISECONDS); // 16 ->約60fps処理
}

void draw() {
  String title = String.format("[frame %d] [fps %6.2f] [volume %4.2f]", frameCount, frameRate, volume);
  surface.setTitle(title);
  
  //processFFT();
  
  background(51,51,51,0);
  //drawAxis();

  for (arcObj ao : sceneObj) { 
    pushMatrix();
      ao.draw();
    popMatrix();
  }
  
  pushMatrix();
    translate(0,0,5);
    for(int i=0; i<360; i++) {
      int[] index = new int[10];
      if(i%((int)360/12) == 0) {
        if(beat.isKick()) {
          noStroke();
          fill(cLimeGreen);
        }else{
          stroke(cLimeGreen);
          strokeWeight(1);
          noFill();
        }
        float d=0.0;
        for(int k=0; k < 10; k++) {
          index[k] = fft_l.freqToIndex(doremi12[i/30] * k);
        }
        for(int k : index) {
          d += fft_l.getBand(k);
        }
        d = volume*d*0.1;
        ellipse(20 * cos(TWO_PI * i/360.- frameCount/1200.), 20 * sin(TWO_PI * i/360.- frameCount/1200.), 2+d, 2+d);
      }
    }
  popMatrix();
  pushMatrix();
    translate(0,0,1);
    for(int i=0; i<360; i++) {
      int[] index = new int[10];
      if(i%((int)360/12) == 0) {
        if(beat.isKick()) {
          stroke(cLiteBlue);
          strokeWeight(1);
          noFill();
        }else{
          noStroke();
          fill(cLiteBlue);
        }
        float d=0.0;
        for(int k=0; k < 10; k++) {
          index[k] = fft_l.freqToIndex(doremi12[i/30] * k);
        }
        for(int k : index) {
          d += fft_r.getBand(k);
        }
        d = volume*d*0.3;
        ellipse(40 * cos(TWO_PI * i/360. + frameCount/1000.), 40 * sin(TWO_PI * i/360.+ frameCount/1000.), 2+d, 2+d);
      }
    }
  popMatrix();
  drawFFT();
  //drawWave();
  
}

void drawFFT() {
  pushMatrix();
    stroke(cMagenta);
    //rotateY(-HALF_PI); 
    strokeWeight(1);
    for(int m=0; m<AUX_CACHE_SIZE;m++) {
      rotateZ( radians(30));
      //translate(0, 0, -1);
      int k = indexlist[ AUX_CACHE_SIZE + AUXcache - m];
      for(int i=0;i<fft_l.specSize();i++) {
        float specR = (FFT_CACHE_R_POW.get(k))[i];
        float specL = (FFT_CACHE_L_POW.get(k))[i];
        line(i/2., 0, 0, i/2.,  volume*5*specR, 0);
        line(-i/2., 0, 0, -i/2., volume*-5*specL, 0);
        //line(i/2., 0, 0, i/2., 0, volume*-5*specR);
        //line(-i/2., 0, 0, -i/2., 0, volume*-5*specL);
      }
    }
  popMatrix();
}

void drawAxis() {
  pushMatrix();
      stroke(255);
      line(-100, 0, 0, 100, 0, 0);
      line(0, -100, 0, 0, 100, 0);
      line(0, 0, -100, 0, 0, 100);
  popMatrix();
}

void drawWave() {
  pushMatrix();
    stroke(cMagenta);
    strokeWeight(1);
    for(int i=1; i<in.bufferSize()/2; i++) {
      translate(0, 0, 0.1);
      if(i%10 ==0) ellipse(0, 0, 300./i + 300*in.mix.get(i/10), 300./i + 300*in.mix.get(i/10) );
    }
  popMatrix();
}

void processFFT() {
  fft_r.forward(in.right);
  fft_l.forward(in.left);
  
  //WAV_CACHE_L.set( AUXcache, System.arraycopy(in.left.toArray()));
  WAV_CACHE_L.set( AUXcache, in.left.toArray().clone());
  WAV_CACHE_R.set( AUXcache, in.right.toArray().clone());
  FFT_CACHE_R_IM.set( AUXcache, fft_r.getSpectrumImaginary().clone());
  FFT_CACHE_R_RE.set( AUXcache, fft_r.getSpectrumReal().clone());
  FFT_CACHE_L_IM.set( AUXcache, fft_l.getSpectrumImaginary().clone());
  FFT_CACHE_L_RE.set( AUXcache, fft_l.getSpectrumReal().clone());
  
  for(int k=0; k<AUX_CACHE_SIZE;k++) {
    float[] POW = new float[1024];
    for(int i=0;i<fft_l.specSize();i++) {
      float im = (FFT_CACHE_L_IM.get(k))[i];
      float re = (FFT_CACHE_L_RE.get(k))[i];
      float spec = sqrt( im*im + re*re );
      POW[i] = spec;
    }
    FFT_CACHE_L_POW.set( AUXcache, POW);
  }
  
  for(int k=0; k<AUX_CACHE_SIZE;k++) {
    float[] POW = new float[1024];
    for(int i=0;i<fft_r.specSize();i++) {
      float im = (FFT_CACHE_R_IM.get(k))[i];
      float re = (FFT_CACHE_R_RE.get(k))[i];
      float spec = sqrt( im*im + re*re );
      POW[i] = spec;
    }
    FFT_CACHE_R_POW.set( AUXcache, POW);
  }

}


class process implements Runnable {  
  public synchronized void run() {  
    AUXcache = (AUXcache+1)%AUX_CACHE_SIZE;
    processFFT();
  }  
}

void keyPressed() {
  switch(key) {
      case 'q':
        volume += 0.05;
        break;
      case 'e':
        volume -= 0.05;
        break;
      default:
        break;
  }
}
