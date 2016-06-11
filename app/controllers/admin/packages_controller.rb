class Admin::PackagesController < Admin::Controller
  def index
    @packages = festival.packages.sort
  end

  def new
    @package = festival.packages.build
  end

  def create
    @package = festival.packages.build(package_params)
    if @package.save
      redirect_to admin_packages_path(festival)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if package.update(package_params)
      redirect_to admin_packages_path(festival)
    else
      render :edit
    end
  end

  def destroy
    package.destroy
    redirect_to admin_packages_path(festival)
  end

  private

  def package_params
    params.require(:package).permit(:name)
  end

  def package
    @package ||= festival.packages.find_by(slug: params[:id])
  end

  helper_method :package
end
