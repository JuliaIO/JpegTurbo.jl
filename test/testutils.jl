# a simplified PSNR to get rid of ImageQualityIndexes and ImageFiltering dependency
assess_psnr(ref::AbstractArray{<:Color3}, x::AbstractArray{<:Color3}) =
    assess_psnr(channelview(RGB.(ref)), channelview(RGB.(x)), 1.0)

assess_psnr(ref::AbstractArray{<:ColorTypes.Transparent3}, x::AbstractArray{<:ColorTypes.Transparent3}) =
    assess_psnr(channelview(ARGB.(ref)), channelview(ARGB.(x)), 1.0)

assess_psnr(ref::AbstractArray{<:AbstractGray}, x::AbstractArray{<:AbstractGray}) =
    assess_psnr(channelview(ref), channelview(x), 1.0)

assess_psnr(ref::AbstractArray{<:Real}, x::AbstractArray{<:Real}, peakval::Real) =
    20log10(peakval) - 10log10(_mse(float.(ref), float.(x)))

function _mse(x, y)
    @assert length(x) == length(y)
    _euclidean(x, y)/(length(x))
end
_euclidean(x, y) = sqrt(sum((x - y) .^ 2))
