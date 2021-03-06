class BloodDrivesController < ApplicationController
  before_action :set_blood_drive, only: [:show, :edit, :update, :destroy]

  # GET /blood_drives
  # GET /blood_drives.json
  def index
    #@blood_drives = BloodDrive.all
    @upcoming_drives = BloodDrive.where(:date.gt => DateTime.now.at_beginning_of_day)
    @past_drives = BloodDrive.where(:date.lt => DateTime.now.at_beginning_of_day)
    @current_drives = BloodDrive.where(:date => DateTime.now.at_beginning_of_day)

  end

  # GET /blood_drives/1
  # GET /blood_drives/1.json
  def show
    @donors = @blood_drive.donations.map(&:donor)
    @donor = Donor.new
  end

  # GET /blood_drives/new
  def new
    @blood_drive = BloodDrive.new
  end

  # GET /blood_drives/1/edit
  def edit
  end

  # POST /blood_drives
  # POST /blood_drives.json
  def create
    @blood_drive = BloodDrive.new(blood_drive_params)

    respond_to do |format|
      if @blood_drive.save
        format.html { redirect_to @blood_drive, notice: 'Blood drive was successfully created.' }
        format.json { render action: 'show', status: :created, location: @blood_drive }
      else
        format.html { render action: 'new' }
        format.json { render json: @blood_drive.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /blood_drives/1
  # PATCH/PUT /blood_drives/1.json
  def update
    respond_to do |format|
      if @blood_drive.update(blood_drive_params)
        format.html { redirect_to @blood_drive, notice: 'Blood drive was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @blood_drive.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blood_drives/1
  # DELETE /blood_drives/1.json
  def destroy
    @blood_drive.destroy
    respond_to do |format|
      format.html { redirect_to blood_drives_url }
      format.json { head :no_content }
    end
  end
  
  
  # POST /blood_drives/:id/add_donor/:donor_id
  def add_donor
    @donor = params[:donor_id] && Donor.find(params[:donor_id])
    @blood_drive = params[:id] && BloodDrive.find(params[:id])
    
    redirect_to @blood_drive, notice: 'Donor already added' and return if Donation.where(donor: @donor, eventable: @blood_drive).count > 0
    
    if @donor && @blood_drive
      donation = Donation.new
      donation.donor = @donor
      donation.eventable = @blood_drive
      donation_saved = donation.save
    else
      donation_saved = false
    end
    
    respond_to do |format|
      if donation_saved
        format.html { redirect_to @blood_drive, notice: 'Donor was successfully added to the blood drive.' }
      else
        format.html { redirect_to @blood_drive, warning: 'Could not add donor to the blood drive.' }
      end
    end
  end
  
  def delete_donor
    #TODO need confirm here
    @blood_drive = params[:id] && BloodDrive.find(params[:id])
    Donation.where(donor_id: params[:donor_id], eventable_id: params[:id]).destroy_all
    redirect_to @blood_drive, notice: 'Donation sucessfully removed'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blood_drive
      @blood_drive = BloodDrive.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def blood_drive_params
      params.require(:blood_drive).permit(:location, :date, :description)
    end
end
