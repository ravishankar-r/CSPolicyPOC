control "CLAMAV Not Installed" do
  impact 0.7
  title "Checking clamav is installed or not"
  describe package('clamav-freshclam') do
    it { should be_installed }
  end
end
