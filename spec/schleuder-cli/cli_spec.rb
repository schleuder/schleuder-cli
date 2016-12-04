require "spec_helper"

describe SchleuderCli do

  before do
    start_api_daemon
  end

  after do
    stop_api_daemon
  end

  it "returns a help message when run without argument" do
    output = run_cli
    expect(output).to include(" help [COMMAND]")
    expect(output).to include(" keys ...")
    expect(output).to include(" lists ...")
    expect(output).to include(" subscriptions ...")
    expect(output).to include(" version")
  end

  it "returns a help message for a subcommand when run without argument" do
    output = run_cli('lists')
    expect(output).to include(" lists delete ")
    expect(output).to include(" lists help [COMMAND]")
    expect(output).to include(" lists list")
    expect(output).to include(" lists list-options")
    expect(output).to include(" lists new ")
    expect(output).to include(" lists set ")
    expect(output).to include(" lists show ")
  end

  it "returns the version" do
    output = run_cli('-v')
    expect(output).to eq(SchleuderCli::VERSION)
  end

  it "shows remote version" do
    output = run_cli(%w[version -r])
    expect(output).to eq('999.99.9')
  end

  it "lists all lists" do
    output = run_cli(%w[lists list])
    expect(output).to eq("something@localhost\ntest15836@localhost bl")
  end
end
