export const GetIpfsUrlFromPinata = (pinataUrl) => {
  var IPFSUrl = pinataUrl;
  // const lastIndex = IPFSUrl.length;
  IPFSUrl = "https://ipfs.io/ipfs/" + IPFSUrl;
  return IPFSUrl;
};
