module ActivitiesHelper
  def activity_image_url(activity, size)
    if activity.image.present?
      activity.image.url(size)
    else
      "http://unsplash.it/640/360/?image=#{activity.id % 40 + 1040}"
    end
  end
end
