require "spec_helper"

describe SchleuderCli do

  it "returns a help message when run without argument" do
    output = run_cli
    expect(output).to include("schleuder-cli help")
    expect(output).to include("schleuder-cli keys")
    expect(output).to include("schleuder-cli lists")
    expect(output).to include("schleuder-cli subscriptions")
    expect(output).to include("schleuder-cli version")
  end

  it "returns a help message for a subcommand when run without argument" do
    output = run_cli('lists')
    expect(output).to_not include("schleuder-cli help")
    expect(output).to include("schleuder-cli lists help")
    expect(output).to include("schleuder-cli lists delete")
    expect(output).to include("schleuder-cli lists list")
    expect(output).to include("schleuder-cli lists list-options")
    expect(output).to include("schleuder-cli lists new")
    expect(output).to include("schleuder-cli lists set")
    expect(output).to include("schleuder-cli lists show")
  end

  it "returns the version" do
    output = run_cli('-v').chomp
    expect(output).to eq(SchleuderCli::VERSION)
  end

end
