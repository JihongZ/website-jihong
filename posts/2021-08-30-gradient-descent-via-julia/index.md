---
title: Gradient Descent Algorithm via julia
date: '2021-08-30'
slug: gradient-descent-via-julia
categories:
  - Tutorial
  - Algorithm
  - julia
tags:
subtitle: 'This tutorial illustrate how to use julia to conduct a gradient descent algorithm'
summary: 'This blog build GD algorithm via Julia programming language'
authors: ['Jihong Zhang']
lastmod: '2021-08-30T19:01:49-07:00'
featured: no
toc: true
---

## Load Julia modules

``` julia
using RDatasets
using DataFrames
```

``` julia
mtcars = dataset("datasets", "mtcars")
```

::: data-frame
<p>32 rows × 12 columns (omitted printing of 4 columns)</p>

<table class="data-frame">

<thead>

<tr>

<th>

</th>

<th>Model</th>

<th>MPG</th>

<th>Cyl</th>

<th>Disp</th>

<th>HP</th>

<th>DRat</th>

<th>WT</th>

<th>QSec</th>

</tr>

<tr>

<th>

</th>

<th title="String">

String

</th>

<th title="Float64">

Float64

</th>

<th title="Int64">

Int64

</th>

<th title="Float64">

Float64

</th>

<th title="Int64">

Int64

</th>

<th title="Float64">

Float64

</th>

<th title="Float64">

Float64

</th>

<th title="Float64">

Float64

</th>

</tr>

</thead>

<tbody>

<tr>

<th>1</th>

<td>Mazda RX4</td>

<td>21.0</td>

<td>6</td>

<td>160.0</td>

<td>110</td>

<td>3.9</td>

<td>2.62</td>

<td>16.46</td>

</tr>

<tr>

<th>2</th>

<td>Mazda RX4 Wag</td>

<td>21.0</td>

<td>6</td>

<td>160.0</td>

<td>110</td>

<td>3.9</td>

<td>2.875</td>

<td>17.02</td>

</tr>

<tr>

<th>3</th>

<td>Datsun 710</td>

<td>22.8</td>

<td>4</td>

<td>108.0</td>

<td>93</td>

<td>3.85</td>

<td>2.32</td>

<td>18.61</td>

</tr>

<tr>

<th>4</th>

<td>Hornet 4 Drive</td>

<td>21.4</td>

<td>6</td>

<td>258.0</td>

<td>110</td>

<td>3.08</td>

<td>3.215</td>

<td>19.44</td>

</tr>

<tr>

<th>5</th>

<td>Hornet Sportabout</td>

<td>18.7</td>

<td>8</td>

<td>360.0</td>

<td>175</td>

<td>3.15</td>

<td>3.44</td>

<td>17.02</td>

</tr>

<tr>

<th>6</th>

<td>Valiant</td>

<td>18.1</td>

<td>6</td>

<td>225.0</td>

<td>105</td>

<td>2.76</td>

<td>3.46</td>

<td>20.22</td>

</tr>

<tr>

<th>7</th>

<td>Duster 360</td>

<td>14.3</td>

<td>8</td>

<td>360.0</td>

<td>245</td>

<td>3.21</td>

<td>3.57</td>

<td>15.84</td>

</tr>

<tr>

<th>8</th>

<td>Merc 240D</td>

<td>24.4</td>

<td>4</td>

<td>146.7</td>

<td>62</td>

<td>3.69</td>

<td>3.19</td>

<td>20.0</td>

</tr>

<tr>

<th>9</th>

<td>Merc 230</td>

<td>22.8</td>

<td>4</td>

<td>140.8</td>

<td>95</td>

<td>3.92</td>

<td>3.15</td>

<td>22.9</td>

</tr>

<tr>

<th>10</th>

<td>Merc 280</td>

<td>19.2</td>

<td>6</td>

<td>167.6</td>

<td>123</td>

<td>3.92</td>

<td>3.44</td>

<td>18.3</td>

</tr>

<tr>

<th>11</th>

<td>Merc 280C</td>

<td>17.8</td>

<td>6</td>

<td>167.6</td>

<td>123</td>

<td>3.92</td>

<td>3.44</td>

<td>18.9</td>

</tr>

<tr>

<th>12</th>

<td>Merc 450SE</td>

<td>16.4</td>

<td>8</td>

<td>275.8</td>

<td>180</td>

<td>3.07</td>

<td>4.07</td>

<td>17.4</td>

</tr>

<tr>

<th>13</th>

<td>Merc 450SL</td>

<td>17.3</td>

<td>8</td>

<td>275.8</td>

<td>180</td>

<td>3.07</td>

<td>3.73</td>

<td>17.6</td>

</tr>

<tr>

<th>14</th>

<td>Merc 450SLC</td>

<td>15.2</td>

<td>8</td>

<td>275.8</td>

<td>180</td>

<td>3.07</td>

<td>3.78</td>

<td>18.0</td>

</tr>

<tr>

<th>15</th>

<td>Cadillac Fleetwood</td>

<td>10.4</td>

<td>8</td>

<td>472.0</td>

<td>205</td>

<td>2.93</td>

<td>5.25</td>

<td>17.98</td>

</tr>

<tr>

<th>16</th>

<td>Lincoln Continental</td>

<td>10.4</td>

<td>8</td>

<td>460.0</td>

<td>215</td>

<td>3.0</td>

<td>5.424</td>

<td>17.82</td>

</tr>

<tr>

<th>17</th>

<td>Chrysler Imperial</td>

<td>14.7</td>

<td>8</td>

<td>440.0</td>

<td>230</td>

<td>3.23</td>

<td>5.345</td>

<td>17.42</td>

</tr>

<tr>

<th>18</th>

<td>Fiat 128</td>

<td>32.4</td>

<td>4</td>

<td>78.7</td>

<td>66</td>

<td>4.08</td>

<td>2.2</td>

<td>19.47</td>

</tr>

<tr>

<th>19</th>

<td>Honda Civic</td>

<td>30.4</td>

<td>4</td>

<td>75.7</td>

<td>52</td>

<td>4.93</td>

<td>1.615</td>

<td>18.52</td>

</tr>

<tr>

<th>20</th>

<td>Toyota Corolla</td>

<td>33.9</td>

<td>4</td>

<td>71.1</td>

<td>65</td>

<td>4.22</td>

<td>1.835</td>

<td>19.9</td>

</tr>

<tr>

<th>21</th>

<td>Toyota Corona</td>

<td>21.5</td>

<td>4</td>

<td>120.1</td>

<td>97</td>

<td>3.7</td>

<td>2.465</td>

<td>20.01</td>

</tr>

<tr>

<th>22</th>

<td>Dodge Challenger</td>

<td>15.5</td>

<td>8</td>

<td>318.0</td>

<td>150</td>

<td>2.76</td>

<td>3.52</td>

<td>16.87</td>

</tr>

<tr>

<th>23</th>

<td>AMC Javelin</td>

<td>15.2</td>

<td>8</td>

<td>304.0</td>

<td>150</td>

<td>3.15</td>

<td>3.435</td>

<td>17.3</td>

</tr>

<tr>

<th>24</th>

<td>Camaro Z28</td>

<td>13.3</td>

<td>8</td>

<td>350.0</td>

<td>245</td>

<td>3.73</td>

<td>3.84</td>

<td>15.41</td>

</tr>

<tr>

<th>25</th>

<td>Pontiac Firebird</td>

<td>19.2</td>

<td>8</td>

<td>400.0</td>

<td>175</td>

<td>3.08</td>

<td>3.845</td>

<td>17.05</td>

</tr>

<tr>

<th>26</th>

<td>Fiat X1-9</td>

<td>27.3</td>

<td>4</td>

<td>79.0</td>

<td>66</td>

<td>4.08</td>

<td>1.935</td>

<td>18.9</td>

</tr>

<tr>

<th>27</th>

<td>Porsche 914-2</td>

<td>26.0</td>

<td>4</td>

<td>120.3</td>

<td>91</td>

<td>4.43</td>

<td>2.14</td>

<td>16.7</td>

</tr>

<tr>

<th>28</th>

<td>Lotus Europa</td>

<td>30.4</td>

<td>4</td>

<td>95.1</td>

<td>113</td>

<td>3.77</td>

<td>1.513</td>

<td>16.9</td>

</tr>

<tr>

<th>29</th>

<td>Ford Pantera L</td>

<td>15.8</td>

<td>8</td>

<td>351.0</td>

<td>264</td>

<td>4.22</td>

<td>3.17</td>

<td>14.5</td>

</tr>

<tr>

<th>30</th>

<td>Ferrari Dino</td>

<td>19.7</td>

<td>6</td>

<td>145.0</td>

<td>175</td>

<td>3.62</td>

<td>2.77</td>

<td>15.5</td>

</tr>

<tr>

<th>⋮</th>

<td>⋮</td>

<td>⋮</td>

<td>⋮</td>

<td>⋮</td>

<td>⋮</td>

<td>⋮</td>

<td>⋮</td>

<td>⋮</td>

</tr>

</tbody>

</table>
:::

``` julia
```

## Julia Function for Gradient Descent

-   learn_rate: the magnitude of the steps the algorithm takes along the slope of the MSE function
-   conv_threshold: threshold for convergence of gradient descent n: number of iternations
-   max_iter: maximum of iteration before the algorithm stopss

```         
function gradientDesc(x, y, learn_rate, conv_threshold, n, max_iter)
    β = rand(Float64, 1)[1]
    α = rand(Float64, 1)[1]
    ŷ = α .+ β .* x
    MSE = sum((y .- ŷ).^2)/n
    converged = false
    iterations = 0

    while converged == false
        # Implement the gradient descent algorithm
        β_new = β - learn_rate*((1/n)*(sum((ŷ .- y) .* x)))
        α_new = α - learn_rate*((1/n)*(sum(ŷ .- y)))
        α = α_new
        β = β_new
        ŷ = β.*x .+ α
        MSE_new = sum((y.-ŷ).^2)/n
        # decide on whether it is converged or not
        if (MSE - MSE_new) <= conv_threshold
            converged = true
            println("Optimal intercept: $α; Optimal slope: $β")
        end
        iterations += 1
        if iterations > max_iter
            converged = true
            println("Optimal intercept: $α; Optimal slope: $β")
        end
    end
end
```

```         
gradientDesc (generic function with 1 method)
```

``` julia
gradientDesc(mtcars[:,:Disp], mtcars[:,:MPG], 0.0000293, 0.001, 32, 2500000)
```

```         
Optimal intercept: 29.599851506041713; Optimal slope: -0.0412151089535404
```

## Compared to linear regression

``` julia
using GLM
linearRegressor = lm(@formula(MPG ~ Disp), mtcars)
```

```         
StatsModels.TableRegressionModel{LinearModel{GLM.LmResp{Vector{Float64}}, GLM.DensePredChol{Float64, LinearAlgebra.CholeskyPivoted{Float64, Matrix{Float64}}}}, Matrix{Float64}}

MPG ~ 1 + Disp

Coefficients:
───────────────────────────────────────────────────────────────────────────
                  Coef.  Std. Error      t  Pr(>|t|)  Lower 95%   Upper 95%
───────────────────────────────────────────────────────────────────────────
(Intercept)  29.5999     1.22972     24.07    <1e-20  27.0884    32.1113
Disp         -0.0412151  0.00471183  -8.75    <1e-09  -0.050838  -0.0315923
───────────────────────────────────────────────────────────────────────────
```

``` julia
```
