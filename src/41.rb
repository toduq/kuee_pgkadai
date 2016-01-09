require 'gnuplot'

graphs = [] # 結果を格納する配列
def f(x)
  1.0/(1.0 + x**2 * 25)
end

# グラフを描画するxの値
sampling_x = (-1.0).step(1.0, 2.0/5000).map{|xi| xi}

# 実際の関数値
graphs.push(
  label: 'f(x)',
  x: sampling_x,
  y: sampling_x.map{|xi| f(xi)}
)

[5.0,10.0,30.0].each do |n|
  # 標本点[4.1.1]
  # x = (-1.0).step(1.0, 2.0/n).map{|xi| xi}
  # 標本点[4.1.2]
  x = 0.upto(n).map{|i| Math.cos((2*(n-i)+1)/(2*n+2)*Math::PI) } 
  graphs.push(
    label: "L#{n}",
    x: sampling_x,
    y: sampling_x.map{|val_x|
      # iごとに計算したLi(x)*f(x)の値の和を取る
      pn = 0.0
      x.each_with_index do |xi, i| 
        # take sum
        li = 1.0
        x.each_with_index do |xj, j|
          next if i == j
          li *= (val_x - xj) / (xi - xj)
        end
        pn += li*f(xi)
      end
      pn
    }
  )
end

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title '4.4.1'
    plot.xlabel 'x'
    plot.ylabel 'y'

    graphs.each do |graph|
      plot.data << Gnuplot::DataSet.new([graph[:x], graph[:y]]) do |ds|
        ds.with = "lines"
        ds.linewidth = 1
        ds.title = graph[:label]
      end
    end
  end
end