require 'gnuplot'
require 'bigdecimal'

def f(x); x**19; end
integral_x = BigDecimal.new('1.0')/20

def romberg(n, a, b)
  # コードの読みやすさの観点から、配列の添え字は0ではなく1から始まるものとする
  def h(i,a,b); (b-a)/(2**(i-1)); end
  r = (n+1).times.map{[]}
  # 合成台形公式によりr[i][1]を計算する
  r[1][1] = (h(1,a,b)/2.0)*(f(a)+f(b))
  2.upto(n).each do |i|
    sigma = 1.upto(2**(i-2)).map{|k| f( a+(2*k-1)*h(i,a,b) )}.inject(&:+)
    r[i][1] = 0.5*( r[i-1][1] + h(i-1,a,b)*sigma )
  end
  # リチャードソンの補外法を計算する
  2.upto(n) do |i|
    2.upto(i) do |j|
      r[i][j] = r[i][j-1] + (r[i][j-1]-r[i-1][j-1])/(4**(j-1)-1)
    end
  end
  r[n][n]
end

ks=[]; daikeis=[]; simps=[]; roms=[]
1.upto(15).each do |k|
  n = 2**k
  dx = 1.0/n

  #　横軸の値
  ks.push(k)

  # 複合台形公式による計算
  d = dx.step(1.0, dx).map{|x|
    (f(x) + f(x-dx)) * dx / 2
  }.inject(&:+)
  daikeis.push(d - integral_x)

  # 複合シンプソン公式による計算
  ss1 = 0.0
  1.upto(n/2-1).each do |i|
    ss1 += f(0 + 1.0/n * 2*i)
  end
  ss2 = 0.0
  1.upto(n/2).each do |i|
    ss2 += f(0 + 1.0/n * (2*i-1))
  end
  s = 1.0/(3.0*n) * (f(1.0)+f(0.0) + 2.0 * ss1 + 4.0*ss2)
  simps.push(s -integral_x)

  # ロンバーグ積分法による計算
  rom = romberg(k, BigDecimal.new('0.0'), BigDecimal.new('1.0'))
  roms.push((rom-integral_x).abs)
end

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title '4.2.1, 4.2.2'
    plot.xlabel 'k'
    plot.ylabel 'dif'
    plot.logscale 'y'

    plot.data << Gnuplot::DataSet.new([ks, daikeis]) do |ds|
      ds.title = 'Trapezium'
      ds.with = "lines"
      ds.linewidth = 1
    end
    plot.data << Gnuplot::DataSet.new([ks, simps]) do |ds|
      ds.title = 'Simpson'
      ds.with = "lines"
      ds.linewidth = 1
    end
    plot.data << Gnuplot::DataSet.new([ks, roms]) do |ds|
      ds.title = 'Romberg'
      ds.with = "lines"
      ds.linewidth = 1
    end
  end
end