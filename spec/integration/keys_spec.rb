require "spec_helper"

describe "#keys" do
  it "imports keys from a file" do
    listname = "testlist-#{rand}@localhost"
    output = run_cli("lists new #{listname} admin@localhost")
    expect(output).to include("List #{listname} successfully created!")

    output = run_cli("keys import #{listname} spec/two_keys.asc")
    expect(output).to eql("Imported: 0x59C71FB38AEE22E091C78259D06350440F759BD3 schleuder@example.org 2016-12-06\nImported: 0xA725BD56B0CA28BF3D05F45D3EBD901AEB9C74E4 first@example.net 2020-04-07\n")
  ensure
    run_cli("lists delete #{listname} --YES")
  end

  it "complains about unreadable file" do
    output = run_cli("keys import something doesnotexist.txt")
    expect(output).to eql("File not found: doesnotexist.txt\n")
  end

  it "tells about failed imports" do
    listname = "testlist-#{rand}@localhost"
    output = run_cli("lists new #{listname} admin@localhost")
    expect(output).to include("List #{listname} successfully created!")

    output = run_cli("keys import #{listname} LICENSE.txt")
    expect(output).to eql("LICENSE.txt did not contain any keys!\n")
  end

  it "properly reports non-existing list" do
    output = run_cli("keys import something spec/example_key.txt")
    expect(output).to eql("Schleuder could not find the requested resource, please check your input.\n")
  end
end

