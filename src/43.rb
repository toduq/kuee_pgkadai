require 'gnuplot'
require 'bigdecimal'
require 'bigdecimal/math'
include BigMath

def romberg(n, a, b, f)
  # コードの読みやすさの観点から、配列の添え字は0ではなく1から始まるものとする
  def h(i,a,b); BigDecimal.new(b-a)/(2**(i-1)); end
  r = (n+1).times.map{[]}
  # 合成台形公式によりr[i][1]を計算する
  r[1][1] = (h(1,a,b)/2.0)*(f[a]+f[b])
  2.upto(n).each do |i|
    sigma = 1.upto(2**(i-2)).map{|k| f[ a+(2*k-1)*h(i,a,b) ]}.inject(&:+)
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

exact_pi = PI(100)
plot_x = []
plot_y = (4).times.map{[]}
f1 = Proc.new{|x| 1/(1+BigDecimal.new(x))}
f2 = Proc.new{|x| (1-BigDecimal.new(x)**2).sqrt(100)}
2.upto(10) do |k|
  plot_x.push k
  plot_y[0].push(romberg(k, 0, 1, f1)*4)
  plot_y[1].push(romberg(k, 0, 1, f2)*4)
  plot_y[2].push(
    romberg(k,0,BigDecimal.new('0.5'),f2)*12 - BigDecimal.new(3).sqrt(100)*12/8
  )
  plot_y[3].push(
    romberg(k,BigDecimal.new('0.5'),1,f2)*6 + BigDecimal.new(3).sqrt(100)*3/4
  )
end
plot_y = plot_y.map{|arr| arr.map{|val| (val-exact_pi).abs}}
Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title '4.3'
    plot.xlabel 'k'
    plot.ylabel 'dif'
    plot.logscale 'y'

    plot_y.each_with_index do |p, i|
      plot.data << Gnuplot::DataSet.new([plot_x, p]) do |ds|
        ds.title = "#{i+1}"
        ds.with = "lines"
        ds.linewidth = 1
      end
    end
  end
end