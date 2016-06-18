class Admin::PackagesController < Admin::Controller
  wrap_parameters :package, include: PackageForm.parameters

  def index
    @packages = festival.packages.sort
  end

  def new
  end

  def create
    if package_form.save
      redirect_to admin_packages_path(festival)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if package_form.save
      redirect_to admin_packages_path(festival)
    else
      render :edit
    end
  end

  def destroy
    package.destroy
    redirect_to admin_packages_path(festival)
  end

  def reorder
    package.remove_from_list
    package.insert_at(params[:position].to_i)
    head :ok
  end

  private

  def package_form
    @package_form ||= PackageForm.new(
      params[:id] ? package : festival.packages.build, params
    )
  end

  def package
    @package ||= festival.packages.find_by(slug: params[:id])
  end

  helper_method :package, :package_form
end
