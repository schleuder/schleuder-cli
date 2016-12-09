require "spec_helper"

describe SchleuderCli do

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
    expect(output).to eq("something@localhost\ntest15836@localhost")
  end

  # A string value.
  it "shows log_level for existing list" do
    output = run_cli(%w[lists show something@localhost log_level])
    expect(output).to eq("debug")
  end

  # An array-value.
  it "shows keywords_admin_only for existing list" do
    output = run_cli(%w[lists show something@localhost keywords_admin_only])
    expect(output).to eq('["subscribe", "unsubscribe", "list-keys"]')
  end

  # A hash-value.
  it "shows bounces_drop_on_headers for existing list" do
    output = run_cli(%w[lists show something@localhost bounces_drop_on_headers])
    expect(output).to eq('{"x-spam-flag"=>"yes", "x-foo"=>"bar"}')
  end

  # A non-existing option
  it "shows error message for non-existing option for existing list" do
    output = run_cli(%w[lists show something@localhost foobar])
    expect(output).to eq('No such option')
  end

  it "lists list-options" do
    output = run_cli(%w[lists list-options])
    expect(output).to eq("bounces_drop_all\nbounces_drop_on_headers\nbounces_notify_admins\nforward_all_incoming_to_admins\nheaders_to_meta\ninclude_list_headers\ninclude_openpgp_header\nkeep_msgid\nkeywords_admin_notify\nkeywords_admin_only\nlanguage\nlog_level\nlogfiles_to_keep\nmax_message_size_kb\nopenpgp_header_preference\npublic_footer\nreceive_admin_only\nreceive_authenticated_only\nreceive_encrypted_only\nreceive_from_subscribed_emailaddresses_only\nreceive_signed_only\nsend_encrypted_only\nsubject_prefix\nsubject_prefix_in\nsubject_prefix_out")
  end

  it "lists keys for existing list" do
    output = run_cli(%w[keys list something@localhost])
    expect(output).to eq("52507B0163A8D9F0094FFE03B1A36F08069E55DE paz@nadir.org\nFE1671DA071B08023A260CC2D2915EC47415257A something-request@localhost")
  end
end
